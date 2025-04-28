from .fsm import RegistrationFSM, ServiceOneFSM, ServiceTwoFSM, ServiceThreeFSM
from typing import Dict

# For now, use an in-memory dict (later, swap for Django session or DB)

class FSMManager:
    def __init__(self):
        self.fsms: Dict[str, Dict[str, object]] = {}  # user_id -> flow -> FSM

    def get_or_create_fsm(self, user_id: str, flow: str):
        if user_id not in self.fsms:
            self.fsms[user_id] = {}
        if flow not in self.fsms[user_id]:
            if flow == "registration":
                self.fsms[user_id][flow] = RegistrationFSM(user_id)
            elif flow == "service-one":
                self.fsms[user_id][flow] = ServiceOneFSM(user_id)
            elif flow == "service-two":
                self.fsms[user_id][flow] = ServiceTwoFSM(user_id)
            elif flow == "service-three":
                self.fsms[user_id][flow] = ServiceThreeFSM(user_id)
        return self.fsms[user_id][flow]

fsm_manager = FSMManager()