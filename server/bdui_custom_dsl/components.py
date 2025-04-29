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
    margin_left: Optional[int] = None
    margin_right: Optional[int] = None
    background_color: Optional[str] = None
    border_radius: Optional[int] = None
    shadow_opacity: Optional[float] = None
    shadow_radius: Optional[float] = None
    shadow_offset_x: Optional[float] = None
    shadow_offset_y: Optional[float] = None
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
        if self.margin_left is not None:
            properties["marginLeft"] = self.margin_left
        if self.margin_right is not None:
            properties["marginRight"] = self.margin_right
        if self.background_color is not None:
            properties["backgroundColor"] = self.background_color
        if self.border_radius is not None:
            properties["borderRadius"] = self.border_radius
        if self.shadow_opacity is not None:
            properties["shadowOpacity"] = self.shadow_opacity
        if self.shadow_radius is not None:
            properties["shadowRadius"] = self.shadow_radius
        if self.shadow_offset_x is not None:
            properties["shadowOffsetX"] = self.shadow_offset_x
        if self.shadow_offset_y is not None:
            properties["shadowOffsetY"] = self.shadow_offset_y

        return {
            "type": "container",
            "properties": properties,
            "children": [child.to_dict() for child in self.children]
        }

@dataclass
class Button(Component):
    action: str  # "request", "toggle", "native"
    event: Optional[str] = None
    uri: Optional[str] = None
    target: Optional[str] = None
    font_size: int = 18
    color: str = "#1E90FF"
    bottomAligned: bool = False
    text: Optional[str] = None
    background_color: Optional[str] = None
    border_radius: Optional[int] = None
    image_uri: Optional[str] = None
    width: Optional[int] = None
    padding: Optional[int] = None
    padding_top: Optional[int] = None
    padding_bottom: Optional[int] = None
    padding_left: Optional[int] = None
    padding_right: Optional[int] = None
    full_width: bool = False
    margin_left: Optional[int] = None
    margin_right: Optional[int] = None
    disabled: bool = False

    def to_dict(self) -> dict:
        properties = {
            "action": self.action,
            "font_size": self.font_size,
            "color": self.color
        }
        if self.text is not None:
            properties["text"] = self.text
        if self.event is not None:
            properties["event"] = self.event
        if self.uri is not None:
            properties["uri"] = self.uri
        if self.target is not None:
            properties["target"] = self.target
        if self.bottomAligned:
            properties["bottomAligned"] = True
        if self.background_color is not None:
            properties["backgroundColor"] = self.background_color
        if self.border_radius is not None:
            properties["borderRadius"] = self.border_radius
        if self.image_uri is not None:
            properties["imageUri"] = self.image_uri
        if self.width is not None:
            properties["width"] = self.width
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
        if self.full_width:
            properties["fullWidth"] = True
        if self.margin_left is not None:
            properties["marginLeft"] = self.margin_left
        if self.margin_right is not None:
            properties["marginRight"] = self.margin_right
        if self.disabled:
            properties["disabled"] = True
        return {"type": "button", "properties": properties}
    
@dataclass
class Checkbox0(Component):
    text: str
    target: str  # Button to enable
    checked: bool = False
    font_size: int = 16
    color: str = "#000000"
    action: Optional[str] = None

    def to_dict(self) -> dict:
        properties = {
            "text": self.text,
            "target": self.target,
            "checked": self.checked,
            "font_size": self.font_size,
            "color": self.color
        }
        if self.action:
            properties["action"] = self.action
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
    margin_top: Optional[int] = None
    margin_bottom: Optional[int] = None
    margin_left: Optional[int] = None
    margin_right: Optional[int] = None

    def to_dict(self) -> dict:
        properties = {"uri": self.uri}
        if self.width is not None:
            properties["width"] = self.width
        if self.height is not None:
            properties["height"] = self.height
        if self.margin_top is not None:
            properties["marginTop"] = self.margin_top
        if self.margin_bottom is not None:
            properties["marginBottom"] = self.margin_bottom
        if self.margin_left is not None:
            properties["marginLeft"] = self.margin_left
        if self.margin_right is not None:
            properties["marginRight"] = self.margin_right
        return {"type": "image", "properties": properties}
    
class Checkbox(Component):
    def __init__(self, label: str, checked: bool = False, event: str = "", action: str = "", target: str = ""):
        # super().__init__(component_type="checkbox")
        self.properties = {
            "label": label,
            "checked": checked,
            "event": event,
            "action": action,
            "target": target,
        }

    def to_dict(self) -> dict:
        return {
            "type": "checkbox",
            "properties": self.properties
        }