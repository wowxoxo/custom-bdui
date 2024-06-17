class Component:
	def to_dict(self):
		raise NotImplementedError("Subclasses should implement this method.")

class Text(Component):
	def __init__(self, text, font_size=14, color="#000000", alignment="left", bold=False):
		self.text = text
		self.font_size = font_size
		self.color = color
		self.alignment = alignment
		self.bold = bold

	def to_dict(self):
		return {
			"type": "text",
			"properties": {
				"text": self.text,
				"font_size": self.font_size,
				"color": self.color,
				"alignment": self.alignment,
				"bold": self.bold
			}
		}

class Container(Component):
	def __init__(self, orientation="vertical", padding=0, padding_top=0, padding_bottom=0, padding_left=0, padding_right=0):
		self.orientation = orientation
		self.padding = padding
		self.padding_top = padding_top
		self.padding_bottom = padding_bottom
		self.padding_left = padding_left
		self.padding_right = padding_right
		self.children = []

	def add_child(self, child):
		self.children.append(child)

	def to_dict(self):
		return {
			"type": "container",
			"properties": {
				"orientation": self.orientation,
				"padding": self.padding,
				"paddingTop": self.padding_top,
				"paddingBottom": self.padding_bottom,
				"paddingLeft": self.padding_left,
				"paddingRight": self.padding_right
			},
			"children": [child.to_dict() for child in self.children]
		}
