 #!/bin/bash
    TOGGLE_FILE="$HOME/.my_toggle_state"

    if [ -e "$TOGGLE_FILE" ]; then
        curl -X POST "https://openapi.api.govee.com/router/api/v1/device/control" -H "Content-Type: application/json" -H "Govee-API-Key: af25940e-97c7-4488-aab6-9cb43bef077e" -d '{"requestId":"uuid‑bulb‑1","payload":{"sku":"H6010","device":"E7:28:98:17:3C:0F:9E:2A","capability":{"type":"devices.capabilities.on_off","instance":"powerSwitch","value":0}}}'
        curl -X POST "https://openapi.api.govee.com/router/api/v1/device/control" -H "Content-Type: application/json" -H "Govee-API-Key: af25940e-97c7-4488-aab6-9cb43bef077e" -d '{"requestId":"uuid‑bulb‑2","payload":{"sku":"H6010","device":"AE:50:98:17:3C:10:E7:10","capability":{"type":"devices.capabilities.on_off","instance":"powerSwitch","value":0}}}'
        rm "$TOGGLE_FILE"
    else
        curl -X POST "https://openapi.api.govee.com/router/api/v1/device/control" -H "Content-Type: application/json" -H "Govee-API-Key: af25940e-97c7-4488-aab6-9cb43bef077e" -d '{"requestId":"uuid‑bulb‑1","payload":{"sku":"H6010","device":"E7:28:98:17:3C:0F:9E:2A","capability":{"type":"devices.capabilities.on_off","instance":"powerSwitch","value":1}}}'
        curl -X POST "https://openapi.api.govee.com/router/api/v1/device/control" -H "Content-Type: application/json" -H "Govee-API-Key: af25940e-97c7-4488-aab6-9cb43bef077e" -d '{"requestId":"uuid‑bulb‑2","payload":{"sku":"H6010","device":"AE:50:98:17:3C:10:E7:10","capability":{"type":"devices.capabilities.on_off","instance":"powerSwitch","value":1}}}'
        touch "$TOGGLE_FILE"
    fi
