from .components import Container, Text, Component
from typing import List
from dataclasses import dataclass, field

@dataclass
class Screen0:
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
	
@dataclass
class Screen(Component):
    screen_id: str
    components: List[Component] = None

    def __post_init__(self):
        self.components = self.components or []

    def add_component(self, component: Component):
        self.components.append(component)

    def to_dict(self) -> dict:
        return {
            "screen": {
                "id": self.screen_id,
                "components": [c.to_dict() for c in self.components]
            }
        }
