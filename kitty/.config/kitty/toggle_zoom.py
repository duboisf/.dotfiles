from kittens.tui.handler import result_handler
from typing import (Final, List, Optional)
import kitty

ZOOMED: Final[str] = " (zoomed)"

def main(args: List[str]) -> None:
    pass

@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss: kitty.boss.Boss) -> None:
    tab: Optional[kitty.Tab] = boss.active_tab
    if tab is not None:
        if tab.current_layout.name == 'stack':
            tab.last_used_layout()
            title = tab.name
            if title is not None and title.endswith(ZOOMED):
                tab.set_title(title[:-len(ZOOMED)])
        else:
            tab.goto_layout('stack')
            tab.set_title(tab.title + ZOOMED)
