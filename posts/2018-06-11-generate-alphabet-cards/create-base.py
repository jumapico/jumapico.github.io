#!/usr/bin/env python3
#
# https://svgwrite.readthedocs.io/en/master/classes/shapes.html#basic-shapes-examples
#
import svgwrite

# A4
WIDTH = 210.0
HEIGHT = 297.0

SIZE_X = WIDTH / 2.0
SIZE_Y = HEIGHT / 3.0

positions = (
    (0, 0),
    (SIZE_X, 0),

    (0, SIZE_Y),
    (SIZE_X, SIZE_Y),

    (0, 2*SIZE_Y),
    (SIZE_X, 2*SIZE_Y),
)

dwg = svgwrite.Drawing('base.svg', size=(WIDTH, HEIGHT), profile='tiny')

i = 1
for x, y in positions:
    dwg.add(
        dwg.rect(
            insert=(x, y),
            size=(SIZE_X, SIZE_Y),
            id='r%d' % i,
            fill='white',
            stroke='black',
            stroke_width=1
            )
        )
    dwg.add(
        dwg.text(
            'PLACEHOLDER',
            insert=(x, y + SIZE_Y),
            id='t%d' % i,
            fill='black',
            font_size='25mm',
            font_family='Arialic Hollow',
            text_align='center'
        )
    )
    i += 1

dwg.save()
