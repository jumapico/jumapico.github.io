Hace unos días pensé en configurar un viejo [HTC][htc wiki] [Desire HD][htc
gsmarena] para que jugara mi hijo.

Haciendo corta la historia: [enladrillé][brick wiki] el celular.

Moraleja en este caso: **no utilizar** imagenes marcadas como **nightly/daily o
similar** para flashear.  Sin duda que luego de pensarlo son las imagenes menos
probadas.  Para la próxima primero con imagenes estables.

[htc wiki]: https://en.wikipedia.org/wiki/HTC_Desire_HD
[htc gsmarena]: https://www.gsmarena.com/htc_desire_hd-3468.php
[brick wiki]: https://en.wikipedia.org/wiki/Brick_(electronics)

Pasos seguidos
--------------

A continuación, y más a guía para un futuro cambio de ROM de celulares:

*   Descargar archivos: recovery, imagen, aplicaciones *Gapps*

    La versión de TWRP debe ser la adecuada para la imagen (ver la
    documentación).

    *   <http://downloads.codefi.re/jrior001/Ace/TWRP-ace-2.8.7.0-unofficial.img>
    *   <http://downloads.codefi.re/mustaavalkosta/cm-12-1-unofficial-ace/nightlies/cm-12.1-20161225-UNOFFICIAL-ace.zip>
    *   <http://downloads.codefi.re/mustaavalkosta/cm-12-1-unofficial-ace/nightlies/cm-12.1-20161225-UNOFFICIAL-ace.zip.md5sum>
    *   <https://androidfilehost.com/?fid=889764386195926957>


*   Copiar los archivos `cm-12.1-20161225-UNOFFICIAL-ace.zip` y
    `gapps-base-arm-5.0.2-20170902-1-signed.zip` a una tarjeta de
    memoria formateada con *FAT32*.

*   Instalar recovery en el teléfono (ver
    <https://twrp.me/htc/htcdesirehd.html>):

    ```
    $ adb reboot bootloader
    $ sudo fastboot flash recovery TWRP-ace-2.8.7.0-unofficial.img
    $ sudo fastboot reboot
    ```

*   Reiniciar el dispositivo (hard reset) y mantener presionado el botón *Power*
    y el de *Volume Down* para entrar al menú de booteo del teléfono. Allí
    elegir la opción *Install* y la imagen `cm-12.1-20161225-UNOFFICIAL-ace.zip`
    en la *SDCard*.


Luego de los pasos anteriores la pantalla queda en negro al bootear el teléfono,
por lo que no se recomienda seguirlos :)

Referencias
-----------

*   https://forum.xda-developers.com/htc-desire-hd/development/rom-cyanogenmod-12-1-nightlies-t3070621
*   https://forum.xda-developers.com/showthread.php?t=2780164
*   https://forum.xda-developers.com/android/software/app-minimal-gapps-gapps-lp-20150107-1-t2997368
*   https://forum.xda-developers.com/htc-desire-s/development/rom-cyanogenmod-12-builds-t2955376
