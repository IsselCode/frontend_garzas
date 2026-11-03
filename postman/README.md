# Verificación local de filtros de créditos

El mock usa datos sintéticos y el contrato `ENDPOINTS_CREDITOS.md` entregado para esta integración. No requiere sesión de Postman ni accede al backend real.

En una terminal:

```powershell
postman simulation run postman/simulations/credits-filters.sim.yaml --port 14010 --output ndjson --no-history
```

En otra:

```powershell
flutter test --dart-define=CREDITS_SIMULATION_URL=http://localhost:14010/backend/api/v1 test/admin/credits_api_simulation_test.dart
```

La prueba usa `ApiClient`, `SalesApi` y `CreditsController` reales para verificar los filtros combinados, la paginación, los caracteres literales de búsqueda y la recuperación después de un error. Los eventos `request` de la simulación muestran las llamadas recibidas. Detén la simulación con Ctrl+C.

Sin `CREDITS_SIMULATION_URL`, la prueba HTTP se omite. Las pruebas de controlador y de interfaz se ejecutan normalmente con `flutter test test/admin`.

El estado de las verificaciones y sus límites está en `simulations/credits-filters.context.yaml`. No se ha verificado autenticación ni autorización contra el servidor real.
