# agents/prompts

Prompts de sistema reutilizables. Los consumen tanto OpenHands como los
gateways (que los montan en `/app/agents`), de modo que el comportamiento del
agente se edita en un solo lugar.

Convención: un archivo Markdown por rol (`system.md`, `revisor.md`, …), con el
alcance y los límites explícitos al principio.
