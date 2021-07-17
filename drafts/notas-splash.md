
Opción vga:


https://www.kernel.org/doc/html/v4.12/admin-guide/kernel-parameters.html

> vga=            [BOOT,X86-32] Select a particular video mode
>                 See Documentation/x86/boot.txt and
>                 Documentation/svga.txt.
>                 Use vga=ask for menu.
>                 This is actually a boot loader parameter; the value is
>                 passed to the kernel using a special protocol.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/x86/boot.txt


https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/svga.txt





Para configurar el splash se utilizará [plymouth][fdo plymouth]

Instalación
-----------

Para instalar `plymouth` con temas por defecto:

```
# apt-get install -V plymouth plymouth-themes
```

Configuración
-------------

### Habilitar uso

Se debe modificar la configuración de `grub`, agregando la opción `splash`.
Esto se hace en el archivo `/etc/default/grub`, en la opción
`GRUB_CMDLINE_LINUX_DEFAULT`. Luego se actualiza la configuración de `grub`
utilizando `update-grub`.

*NOTA: conviene usar la opción `splash` junto con `quiet`, para que no se
muestren en consola los mensajes del kernel al bootear.*

*TIP: para agregar un retardo se puede modificar la opción `ShowDelay` en el
archivo `/etc/plymouth/plymouthd.conf` o utilizar el comando `sleep` al final
del archivo `/etc/rc.local`.*

### Elegir tema

Para ver los temas disponibles se puede utilizar el comando
`plymouth-set-default-theme --list`.

Una descripción de los temas se puede encontrar en la descripción del paquete
(`apt show plymouth-themes`):

> This package provides the following themes:
> .
>  * fade-in: features a centered logo that fades in and out while stars twinkle
>    around the logo during system boot up.
>  * glow: features a pie chart as progress indicator.
>  * script: features a simple base theme.
>  * solar: features a blue flamed sun with animated solar flares.
>  * spinfinity: features a centered logo and animated spinner that spins in the
>    shape of an infinity sign.
>  * spinner: features a simple theme with a small spinner on a dark background.

Para establecer el tema se utiliza `plymouth-set-default-theme -R`, por ejemplo:

```
# plymouth-set-default-theme -R spinfinity
```

### Utilizar framebuffer

**Como se indica en el [ticket 14503][ticket 14503] de virtualbox, no es
posible utilizar `plymouth` con `virtualbox`, por lo cual se utilizará el
framebuffer para visualizar el splash.**

[ticket 14503]: https://www.virtualbox.org/ticket/14503

Siguiendo las indicaciones en la [wiki de Arch][wiki arch uvesafb] se configura
el uso del driver `uvesafb`.

Primero se instala el paquete `v86d`:

```
# apt-get install -V v86d
```

Luego se define la resolución que utilizará `uvesafb`, en este caso se utilizará
la mayor resolución soportada por vesa, que es *1280x1024*.
Para ver los [modos definidos por vesa][wikipedia vesa modes] consultar
wikipedia.

Del post [High-resolution text console with uvesafb and Debian][blog samat], se
obtienen los pasos a seguir para la configuración:


```
# echo 'GRUB_GFXMODE=800x600' >> /etc/default/grub
# update-grub
# echo 'FRAMEBUFFER=y' > /etc/initramfs-tools/conf.d/splash
# echo 'uvesafb mode_option=800x600-24 scroll=ywrap' >> /etc/initramfs-tools/modules
# echo 'options uvesafb mode_option=800x600-24 scroll=ywrap' > /etc/modprobe.d/uvesafb.conf
# plymouth-set-default-theme spinfinity --rebuild-initrd
```

[wiki arch uvesafb]: https://wiki.archlinux.org/index.php/Uvesafb
[blog samat]: https://blog.samat.org/2010/11/09/High-resolution-text-console-with-uvesafb-and-Debian/
[blog rsaffi]: https://blog.rsaffi.com/2017/08/how-to-run-debian-9-1-stretch-with-proprietary-nvidia-driver-and-uvesafb/
[wikipedia vesa modes]: https://en.wikipedia.org/wiki/VESA_BIOS_Extensions#Modes_defined_by_VESA





[fdo plymouth]: https://www.freedesktop.org/wiki/Software/Plymouth/
[wiki arch plymouth]: https://wiki.archlinux.org/index.php/plymouth


Referencias
-----------

* <https://wiki.archlinux.org/index.php/Uvesafb>
* <https://developer.toradex.com/knowledge-base/splash-screen-linux>
* <http://www.randomlinuxstuff.tk/2013/05/fix-ubuntu-boot-screen-after-installing.html>

Problemas
---------

### Problema al configurar con directorio `70-persistent-net.rules`

Un hack usual para que en la imagen no se genere el archivo
`/etc/udev/rules.d/70-persistent-net-rules` es crear un directorio con dicho
nombre (ver [imagenes de bento][hack persistent net rules]).
Este hack genera un error con la etapa de configuración al instalar `plymouth`:

```
# apt-get install -V plymouth plymouth-themes
...
update-initramfs: Generating /boot/initrd.img-4.9.0-8-686-pae
cp: -r not specified; omitting directory '/etc/udev/rules.d/70-persistent-net.rules'
E: /usr/share/initramfs-tools/hooks/udev failed with return 1.
update-initramfs: failed for /boot/initrd.img-4.9.0-8-686-pae with 1.
dpkg: error processing package initramfs-tools (--configure):
 subprocess installed post-installation script returned error exit status 1
Errors were encountered while processing:
 initramfs-tools
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

El problema se soluciona eliminando el archivo y reconfigurando.

[hach persistent net rules]: https://github.com/chef/bento/blob/master/debian/scripts/networking.sh
