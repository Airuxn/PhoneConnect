# PocketMCP control playbook (any Android device)

## GOUDEN REGEL: Verifieer na ELKE actie

**Geldt voor de HELE telefoon** — Termux, Chrome, Instellingen, Camera, alles.

```
Actie → screen_state → Klopt het? → Zo nee: herstel → Pas dan volgende stap
```

### Wat checken in screen_state

1. **foreground_package** — ben ik in de juiste app?
2. **nodes / content_description** — klopt scherminhoud?
3. **launch_app** — `launch_verified: true` EN screen_state bevestigt

---

## Termux typen (handmatig via MCP)

```
focus (720,1200) → keyboard mode (q probe) → ABC indien cijfers
Ctrl+U (313,1552 + u 956,2170) → verify lege prompt
type per letter + verify → Enter (1280,2720) → verify output
```

---

## Bekende beperkingen

| Tool | Status |
|------|--------|
| tap + screen_state | ✅ Werkt |
| launch_app | ✅ Werkt |
| take_screenshot | ❌ Activity context error |
| ADB screencap | ❌ device offline (wireless ADB niet geautoriseerd) |
| shell input text | ❌ geblokkeerd |

---

## Valkuilen

1. y=1356–1618 = Termux extra keys, NIET Samsung keyboard
2. Numbers keyboard → letters worden cijfers → STOP, tap ABC
3. Blind batch-tappen zonder verify = garbage input
4. Ctrl+U: u op (956,2170), NIET (1000,2050)
