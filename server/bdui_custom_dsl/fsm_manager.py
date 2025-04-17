from .fsm import RegistrationFSM
from typing import Dict

# For now, use an in-memory dict (later, swap for Django session or DB)

class FSMManager:
    def __init__(self):
        self.fsms: Dict[str, RegistrationFSM] = {}

    def get_or_create_fsm(self, user_id: str) -> RegistrationFSM:
        if user_id not in self.fsms:
            self.fsms[user_id] = RegistrationFSM(user_id)
        return self.fsms[user_id]

fsm_manager = FSMManager()