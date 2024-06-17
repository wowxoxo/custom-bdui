from .components import Container, Text, Component
from typing import List
from dataclasses import dataclass, field

@dataclass
class Screen:
	screen_id: str
	components: List[Component] = field(default_factory=list)

	def add_component(self, component: Component) -> None:
		self.components.append(component)

	def to_dict(self) -> dict:
		return {
			"screen": {
				"id": self.screen_id,
				"components": [component.to_dict() for component in self.components]
			}
		}
