from .components import Container, Text

class Screen:
	def __init__(self, screen_id):
		self.screen_id = screen_id
		self.components = []

	def add_component(self, component):
		self.components.append(component)

	def to_dict(self):
		return {
			"screen": {
				"id": self.screen_id,
				"components": [component.to_dict() for component in self.components]
			}
		}
