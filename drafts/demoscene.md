Varios relacionados a demoscene

* [Memories](http://www.sizecoding.org/wiki/Memories)
  ```
  $ wget 'https://hellmood.111mb.de//memories2.zip'
  $ unzip memories2.zip
  $ nasm memories.asm -fbin -o memories.com
  $ dosbox -conf dosbox-0.74-3.conf memories.com
  <Ctrl>+F9 to quit
  ```
* pyrit como bootloader
  ```
  $ wget --content-disposition 'http://git.annexia.org/?p=pyrit.git;a=blob_plain;f=pyrit.asm'
  $ nasm pyrit.asm -fbin -o pyrit.bin
  $ qemu-system-x86_64 -hda pyrit.bin
  ```
* [Teach Yourself Demoscene in 14 Days](https://github.com/psenough/teach_yourself_demoscene_in_14_days)
* [Christmas Tree](https://github.com/anvaka/atree)
* [Voxel Space](https://github.com/s-macke/VoxelSpace)
* [RAY TRACING ATINY PROCEDURAL PLANET](https://casual-effects.com/research/McGuire2019ProcGen/McGuire2019ProcGen.pdf)
