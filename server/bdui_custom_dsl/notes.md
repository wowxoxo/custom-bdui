# some notes

## requests to fsm
### without token
```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/next -H "Content-Type: application/json" -d '{"user_id": "test_user", "event": "tap_register"}'
```

### with token
```
curl -c cookies.txt http://127.0.0.1:8000/bdui-dsl/get-csrf-token/
```

```
CSRF_TOKEN=$(grep csrftoken cookies.txt | awk '{print $7}')

curl -X POST -b cookies.txt \
  -H "Content-Type: application/json" \
  -H "X-CSRFToken: $CSRF_TOKEN" \
  -d '{"user_id": "test_user", "event": "tap_register"}' \
  http://127.0.0.1:8000/bdui-dsl/fsm/next
```

## FSM debugging
```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/next -H "Content-Type: application/json" -d '{"user_id": "test_user", "event": "tap_register"}'
```
Should return screen_id: "auth".


```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/next -H "Content-Type: application/json" -d '{"user_id": "test_user", "event": "auth_fail"}'
```
Should return screen_id: "not_enough_rights"


```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/next -H "Content-Type: application/json" -d '{"user_id": "test_user", "event": "auth_success"}'
```
Should return screen_id: "services"


### Debug service one
```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/current -H "Content-Type: application/json" -d '{"user_id": "test_user", "flow": "service-one"}'
```
Returns screen_id: "service-one.get".


```
curl -X POST http://127.0.0.1:8000/bdui-dsl/fsm/next -H "Content-Type: application/json" -d '{"user_id": "test_user", "flow": "service-one", "event": "continue"}'
```
Returns screen_id: "service-one.service-center-visit".


