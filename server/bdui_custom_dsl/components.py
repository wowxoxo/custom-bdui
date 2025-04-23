from typing import List, Optional, Union
from dataclasses import dataclass, field

@dataclass
class Component:
	def to_dict(self):
		raise NotImplementedError("Subclasses should implement this method.")

@dataclass
class Text(Component):
	text: str
	font_size: int = 14
	color: str = "#000000"
	alignment: str = "left"
	bold: bool = False
	padding: Optional[int] = None
	padding_top: Optional[int] = None
	padding_bottom: Optional[int] = None
	padding_left: Optional[int] = None
	padding_right: Optional[int] = None
	action: Optional[str] = None
	uri: Optional[str] = None
	event: Optional[str] = None

	def to_dict(self) -> dict:
		properties = {
			"text": self.text,
			"font_size": self.font_size,
			"color": self.color,
			"alignment": self.alignment,
			"bold": self.bold
		}
		if self.padding is not None:
			properties["padding"] = self.padding
		if self.padding_top is not None:
			properties["paddingTop"] = self.padding_top
		if self.padding_bottom is not None:
			properties["paddingBottom"] = self.padding_bottom
		if self.padding_left is not None:
			properties["paddingLeft"] = self.padding_left
		if self.padding_right is not None:
			properties["paddingRight"] = self.padding_right
		if self.action is not None:
			properties["action"] = self.action
		if self.uri is not None:
			properties["uri"] = self.uri
		if self.event is not None:
			properties["event"] = self.event

		return {
			"type": "text",
			"properties": properties
		}

@dataclass
class Container(Component):
    orientation: str = "vertical"
    padding: Optional[int] = None
    padding_top: Optional[int] = None
    padding_bottom: Optional[int] = None
    padding_left: Optional[int] = None
    padding_right: Optional[int] = None
    children: List[Component] = field(default_factory=list)

    def __post_init__(self):
        self.children = self.children or []

    def add_child(self, child: Optional[Component]) -> 'Container':
        if child is not None:
            self.children.append(child)
        return self

    def to_dict(self) -> dict:
        properties = {
            "orientation": self.orientation,
        }
        if self.padding is not None:
            properties["padding"] = self.padding
        if self.padding_top is not None:
            properties["paddingTop"] = self.padding_top
        if self.padding_bottom is not None:
            properties["paddingBottom"] = self.padding_bottom
        if self.padding_left is not None:
            properties["paddingLeft"] = self.padding_left
        if self.padding_right is not None:
            properties["paddingRight"] = self.padding_right

        return {
            "type": "container",
            "properties": properties,
            "children": [child.to_dict() for child in self.children]
        }

@dataclass
class Button(Component):
    text: str
    action: str  # "request", "toggle", "native"
    event: Optional[str] = None
    uri: Optional[str] = None
    target: Optional[str] = None
    font_size: int = 18
    color: str = "#1E90FF"
    bottomAligned: bool = False

    def to_dict(self) -> dict:
        properties = {
            "text": self.text,
            "action": self.action,
            "font_size": self.font_size,
            "color": self.color
        }
        if self.event is not None:
            properties["event"] = self.event
        if self.uri is not None:
            properties["uri"] = self.uri
        if self.target is not None:
            properties["target"] = self.target
        if self.bottomAligned:
             properties["bottomAligned"] = True
        return {"type": "button", "properties": properties}
    
@dataclass
class Checkbox(Component):
    text: str
    target: str  # Button to enable
    checked: bool = False
    font_size: int = 16
    color: str = "#000000"

    def to_dict(self) -> dict:
        return {
            "type": "checkbox",
            "properties": {
                "text": self.text,
                "target": self.target,
                "checked": self.checked,
                "font_size": self.font_size,
                "color": self.color
            }
        }

@dataclass
class Image(Component):
    uri: str
    width: Optional[int] = None
    height: Optional[int] = None

    def to_dict(self) -> dict:
        properties = {"uri": self.uri}
        if self.width is not None:
            properties["width"] = self.width
        if self.height is not None:
            properties["height"] = self.height
        return {"type": "image", "properties": properties}