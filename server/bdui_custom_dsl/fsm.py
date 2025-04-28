from transitions import Machine
from dataclasses import dataclass
from typing import Dict, Optional
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class UserFlow:
    user_id: str
    flow: str
    state: str

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
                {"trigger": "tap_register", "source": "not_enough_rights", "dest": "auth"},
                {"trigger": "tap_register", "source": "auth", "dest": "auth"},  # Allow retry
                {"trigger": "auth_success", "source": "auth", "dest": "services"},
                {"trigger": "auth_fail", "source": "auth", "dest": "not_enough_rights"},
                {"trigger": "back", "source": ["auth", "not_enough_rights"], "dest": "need_register"},
                {"trigger": "reset", "source": "*", "dest": "need_register"},  # Reset from any state
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

class ServiceOneFSM:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.flow = "service-one"
        self.machine = Machine(
            model=self,
            states=["get", "service-center-visit", "points-list", "point-details", "exit"],
            initial="get",
            transitions=[
                {"trigger": "continue", "source": "get", "dest": "service-center-visit"},
                {"trigger": "select-address", "source": "service-center-visit", "dest": "points-list"},
                {"trigger": "select-point", "source": "points-list", "dest": "point-details"},
                {"trigger": "back", "source": "service-center-visit", "dest": "get"},
                {"trigger": "back", "source": "points-list", "dest": "service-center-visit"},
                {"trigger": "back", "source": "point-details", "dest": "points-list"},
                {"trigger": "back", "source": "get", "dest": "exit"},
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
    
class ServiceTwoFSM:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.flow = "service-two"
        self.machine = Machine(
            model=self,
            states=["get", "details", "exit"],
            initial="get",
            transitions=[
                {"trigger": "continue", "source": "get", "dest": "details"},
                {"trigger": "complete", "source": "details", "dest": "exit"},
                {"trigger": "back", "source": "details", "dest": "get"},
                {"trigger": "back", "source": "get", "dest": "exit"},
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

class ServiceThreeFSM:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.flow = "service-three"
        self.machine = Machine(
            model=self,
            states=["docs-accept", "details", "exit"],
            initial="docs-accept",
            transitions=[
                {"trigger": "accept-docs", "source": "docs-accept", "dest": "details"},
                {"trigger": "continue", "source": "details", "dest": "exit"},
                {"trigger": "back", "source": "details", "dest": "docs-accept"},
                {"trigger": "back", "source": "docs-accept", "dest": "exit"},
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