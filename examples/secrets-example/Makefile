default: test

export UV_NO_SYNC=0

dist: test
	pur wrap

test:
	uv run --group dev robot test_secrets.robot
