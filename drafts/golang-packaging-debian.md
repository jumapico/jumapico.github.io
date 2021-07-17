Experiencias al empaquetar paquetes de golang en debian
=======================================================

Actualmente estoy interesado en utilizar [rkt][rkt] en lugar de docker.
Sobre porqué rkt en lugar de docker se puede comenzar por
<https://coreos.com/rkt/docs/latest/rkt-vs-other-projects.html#rkt-vs-docker>.

Una vez decidido a utilizar rkt el siguiente paso es construir una imagen para
utilizar. El la [documentación de
rkt](https://coreos.com/rkt/docs/latest/getting-started-guide.html#create-the-image)
se sugiere utilizar [acbuild][acbuild], pero como puede verse en la página de
github:

> This project is currently unmaintained
>
> ...
>
> For those looking for an OCI image manipulation tool that is actively
> maintained, [umoci][umoci] or [buildah][buildah] might be able to fill the
> role.

Por lo que queda elegir entre uno de los dos.

Independientemente de cual se elija, ambas se apoyan en [skopeo][skopeo]. De su
sitio web:

> skopeo is a command line utility that performs various operations on container
> images and image repositories.

Como la utilidad [skopeo][skopeo] no se encuentra empaquetada en debian, así
como tampoco umoci o buildah y es esta es una dependencia común me embarqué en
intentar construir el paquete [skopeo][skopeo] para debian.

Así que se pasó de rkt a buildah/umoci a skopeo a empaquetar skopeo para debian.
Recuerda un poco al capítulo [Don't shave
yaks](https://books.google.com.uy/books?id=oVadw8Jf0cYC&pg=PA67) del
libro [The productive programmer](http://shop.oreilly.com/product/9780596519544.do)
de [Neal Ford](http://nealford.com/books/).

A continuación (en este post y siguientes) se comentarán las experiencias
obtenidas al realizar dicho empaquetado.









Lo que más me motiva es no tener que utilizar un
Interesado en construir imagenes de contenedores para utilizar con [rkt][rkt].

[rkt]: https://coreos.com/rkt/
[acbuild]: https://github.com/containers/build
[umoci]: https://umo.ci/
[buildah]: https://github.com/projectatomic/buildah
[skopeo]: https://github.com/projectatomic/skopeo

Build local
-----------

Se comenzará por probar de construir el programa *skopeo* en una instalación de
*debian buster* (testing), siguiendo las instrucciones de la [página de proyecto
de skopeo](https://github.com/projectatomic/skopeo):

### Instalación de dependencias

Siguiendo las instrucciones de la sección *Building without a container*, se
reemplazan los nombres de paquete de las dependencias de *fedora*:

```
Fedora$ sudo dnf install gpgme-devel libassuan-devel btrfs-progs-devel device-mapper-devel ostree-devel
```

por sus contrapartes en *debian*:

```
$ sudo apt-get install -qVys libgpgme-dev libassuan-dev btrfs-progs libdevmapper-dev libostree-dev
```

Se descarga el código fuente, en nuestro caso la release `0.1.28`:

```
$ export version=0.1.28
$ wget -O skopeo-${version}.tar.gz "https://github.com/projectatomic/skopeo/archive/v${version}.tar.gz"
```

Se descomprime y se genera el ejecutable:

```
$ tar xf skopeo-${version}.tar.gz
$ cd skopeo-${version}
$ make binary-local
```

La imagen se construye sin problemas.

Creación de paquete debian
--------------------------

Ya se vió que es factible compilar y ejecutar el programa *skopeo* en debian.
Ahora se buscará crear el paquete debian correspondiente.

Como el lenguaje en el cual está escrito el programa es *go* (golang) se
seguirá la documentación del equipo
[pkg-go](https://go-team.pages.debian.net/) de debian.

En la [página sobre
empaquetamiento](https://go-team.pages.debian.net/packaging.html) se explicita
que:

1.  > All Go packages are maintained in git and must be buildable using
    > git-buildpackage.

2.  > Your library package, e.g. golang-github-lib-pq-dev, needs to have all the
    > other Go libraries it depends on in its Depends line. The dependencies
    > need to be available at build time to run the tests (if any) and at
    > installation time so that other packages can be built.

De lo anterior: se debe utilizar un repositorio git y `git-buildpackage` para
generar el paquete deb y se deben crear paquetes para todas las librerías de las
que dependa skopeo.

### Estimación del trabajo

El programa `dh-make-golang` (paquete `dh-make-golang`) posee la opción de
calcular cuantas dependencias deben empaquetarse para poder construir el binario
de *skopeo*:

```
$ dh-make-golang estimate github.com/projectatomic/skopeo
...
2018/05/07 15:00:55 Bringing github.com/projectatomic/skopeo to Debian requires packaging the following Go packages:
github.com/ostreedev/ostree-go
k8s.io/client-go
github.com/containers/storage
github.com/opencontainers/image-tools
github.com/containers/image
gopkg.in/gemnasium/logrus-airbrake-hook.v2
github.com/projectatomic/skopeo
github.com/dsnet/compress
github.com/mtrmac/gpgme
```

Bien, son algunos paquetes.

Se comenzará por empaquetar `github.com/ostreedev/ostree-go`.

### Empaquetando `github.com/ostreedev/ostree-go`

Según la página <https://go-team.pages.debian.net/packaging.html>, el nombre del
paquete será `golang-github-ostreedev-ostree-go-dev`.

Para realizar el paquete se siguen las indicaciones de la página
<https://people.debian.org/~stapelberg/2015/07/27/dh-make-golang.html>.

Primero se crean los archivos del paquete utilizando `dh-make-golang`:

```
$ export DEBFULLNAME="Juan Picca"
$ export DEBEMAIL="jumapico@gmail.com"
$ dh-make-golang make github.com/ostreedev/ostree-go
```

No olvidar las variables de entorno `DEBFULLNAME` y `DEBEMAIL`, sinó los
archivos generados por `dh-make-golang` tendrán un nombre de usuario incorrecto
(el del sistema).

### Empaquetando `github.com/containers/storage`.

`dh-make-golang` detecta que `storage` es un programa:

```
$ dh-make-golang make github.com/containers/storage
2018/05/15 05:18:59 Assuming you are packaging a program (because "github.com/containers/storage/cmd/containers-storage" defines a main package), use -type to override
```

por lo que se debe utilizar la opción `-type library` para construir el paquete:

```
$ dh-make-golang make -type library github.com/containers/storage
```
