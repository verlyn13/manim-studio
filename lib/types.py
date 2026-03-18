"""Project-wide type aliases for manim scene development."""

from collections.abc import Sequence

from manim import VGroup
from manim.typing import Point3D
from manim.utils.color.core import ParsableManimColor

# A card is a VGroup with a .label attribute — structural convention
type CardMobject = VGroup

# Color maps: label -> color
type ColorMap = dict[str, ParsableManimColor]

# Grid layout specification
type GridSpec = tuple[int, int]  # (rows, cols)

# Sequence of labels used across card/hand factories
type LabelSequence = Sequence[str]

# Position list from grid layout
type PositionList = list[Point3D]
