import json

with open('timeline.json', 'r') as f:
    data = json.load(f)

events = data.get('traceEvents', data) if isinstance(data, dict) else data

long_events = []
notify_events = []
build_events = []

for e in events:
    if not isinstance(e, dict):
        continue
    name = e.get('name', '')
    dur = e.get('dur', 0)
    
    if name == 'RoutineBuilderController.notifyListeners' or 'notifyListeners' in name:
        notify_events.append(e)
    if name == 'Build' and dur > 16000:
        build_events.append(e)
    if dur > 16000 and name in ('UI Thread', 'Raster Thread', 'MessageLoop::RunTask', 'VsyncProcessCallback'):
        long_events.append(e)

print(f"Total events: {len(events)}")
print(f"Total notifyListeners: {len(notify_events)}")
print(f"Total Builds > 16ms: {len(build_events)}")
print(f"Total Long Events: {len(long_events)}")

# If there's a custom trace event for RoutineBuilderController
cnt = 0
for e in events:
    if isinstance(e, dict) and 'RoutineBuilderController' in e.get('name', ''):
        cnt += 1
print(f"RoutineBuilderController mentions in timeline: {cnt}")
