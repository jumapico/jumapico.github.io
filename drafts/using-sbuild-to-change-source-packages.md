Objetivo
--------

Se quieren agregar cambios al paquete [supercat][pdo supercat] para hacerlo
reproducible en *debian testing (buster)*.

Como no se desean instalar las dependencias de construcción en el sistema
(`apt-get build-dep`), se quiere utilizar un *entorno schroot* para crear el
**source** del paquete utilizando `sbuild`.

En lo que sigue se supone familiaridad con el [nuevo método para probar la
reproducibilidad de un paquete en debian][wdo rb howto new method].

Esto está asociado al post [setup del nuevo método de pruebas para paquetes
reproducibles en debian](/2018/11/setup-reproducible-builds-new-method-for-debian/).

[pdo supercat]: https://packages.debian.org/supercat
[wdo rb howto newer method]: https://wiki.debian.org/ReproducibleBuilds/Howto#Newer_method

Creación de schroot
-------------------

Se desea generar un nuevo schroot que contendrá las dependencias de construcción
del paquete `supercat`. Para obtener estas se puede utilizar

```
$ apt-cache showsrc supercat | grep ^Build-Depends:
Build-Depends: autotools-dev, quilt, autoconf, automake
```

Por lo que utilizaremos

```
$ sudo sbuild-createchroot --chroot-prefix=devel-supercat-buster \
    --include=eatmydata,ccache,gnupg,devscripts \
    --include=$(apt-cache showsrc supercat | grep -oP '^Build-Depends: \K.*$' | tr -d ' ')
    buster \
    /srv/chroot/devel-supercat-buster-amd64-sbuild \
    http://localhost:3142/deb.debian.org/debian
```

Aquí se agregan los paquetes `eatmydata`, `ccache` y `gnupg` ya que estos son
incluidos en el `schroot` utilizado para construir el paquete de forma
reproducible.
El paquete `devscripts` se agrega ya que posee varias utilidades y dependencias
útiles para empaquetar que una vez instaladas se espera disminuyan la cantidad
de dependencias a instalar.
Por último, se agregan las dependencias

porque estos son agregados a

el paquete [devscripts][pdo
devscripts].

Para crearlo se utiliza


[pdo devscripts]: https://packages.debian.org/devscripts

Preparación de archivos
-----------------------

Para construir un paquete se deben descargar primero los fuentes del mismo:

```
$ mkdir -p ~/workspace-rb; cd ~/workspace-rb
$ apt-get source supercat/buster
```

Para generar un cambio se incrementará la versión del paquete debian:

```
$ cd ~/workspace-rb/supercat-0.5.5/
$ dch -i "Test"
```

Uso del schroot - session
-------------------------

Para instalar el paquete `devscripts` en el `schroot` recién creado se utiliza:

```
$ sudo schroot -c devel-buster-amd64-sbuild -d / -- apt-get install -V devscripts
```


----

Para obtener **solo** el paquete fuente:

```
$ sbuild -c devel-buster-amd64-sbuild --source --no-arch-any --no-arch-all supercat-0.5.5/
```

Ver <https://manpages.debian.org/stretch/sbuild/sbuild.1.en.html#BUILD_ARTIFACTS>

----

Actualizar el schroot:

```
$ sudo sbuild-update --update --upgrade --clean devel-buster-amd64-sbuild
```

Install build depends packages in schroot:

```
$ apt-cache showsrc supercat | grep '^Build-Depends: \K'
Build-Depends: autotools-dev, quilt, autoconf, automake
```
