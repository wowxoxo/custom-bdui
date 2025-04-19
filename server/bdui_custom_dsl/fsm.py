from transitions import Machine
from dataclasses import dataclass
from typing import Dict, Optional
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class UserFlow:
    user_id: str
    flow: str  # e.g., "registration"
    state: str  # e.g., "need_register"

class RegistrationFSM:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.flow = "registration"
        self.machine = Machine(
            model=self,
            states=["need_register", "auth", "services", "not_enough_rights"],
            initial="need_register",
            transitions=[
                {"trigger": "tap_register", "source": "need_register", "dest": "auth"},
                {"trigger": "auth_success", "source": "auth", "dest": "services"},
                {"trigger": "auth_fail", "source": "auth", "dest": "not_enough_rights"},
                {"trigger": "back", "source": ["auth", "not_enough_rights"], "dest": "need_register"},
            ],
        )

    def get_state(self) -> str:
        return self.state

    def trigger_event(self, event: str) -> bool:
        try:
            logger.info(f"Triggering {event} from {self.state} for user {self.user_id}")
            self.trigger(event)
            logger.info(f"Transitioned to {self.state}")
            return True
        except Exception as e:
            logger.error(f"FSM error: {e}")
            return False

    def to_dict(self) -> Dict:
        return {"user_id": self.user_id, "flow": self.flow, "state": self.state}