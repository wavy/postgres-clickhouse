#!/bin/sh
export TAG="${1:-nightly}"
export GLOB_PREFIX="${2}"

# Clean up
docker-compose down -v || true

# Apply template
cat docker-compose-template.yml | envsubst > docker-compose.yml

for test_script in ./tests/${GLOB_PREFIX}*.sh; do
    # Start up and give some time for boot
    docker-compose up -d
    sleep 5

    echo "$test_script ..."
    "$test_script"

    if [ "$?" != 0 ]; then
        echo ""
        echo "========================"
        echo " TEST FAILED"
        echo " $test_script"
        echo "========================"
        exit 1
    fi
    docker-compose down -v
    echo "$test_script ... OK"
done

set +x
set +e
echo ""
echo "========================"
echo " ALL TESTS PASSED"
echo "========================"
