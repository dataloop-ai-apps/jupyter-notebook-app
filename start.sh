python3 -m pip install tornado==6.4
python3 -m pip install requests==2.31.0

python -m uvicorn "functions.app:app" \
        --reload \
        --host="0.0.0.0" \
        --port=5463 \
        --timeout-keep-alive=60 \
        2>&1 | tee output.log &

jupyter lab --no-browser \
            --ServerApp.allow_remote_access=true \
            --ServerApp.disable_check_xsrf=true \
            --ServerApp.port=8888 \
            --ServerApp.ip='0.0.0.0' \
            --ServerApp.token='' \
            --ServerApp.password='' \
            --ServerApp.root_dir='/tmp' \
            --ServerApp.base_url='/jupyter' \
            --ServerApp.allow_origin=* \
            --ServerApp.tornado_settings='{"headers": {"Access-Control-Allow-Origin": "*", "Content-Security-Policy": "frame-ancestors self * "}}' \
            2>&1 | tee -a output.log &

sudo cp /tmp/app/nginx.conf /etc/nginx/conf.d
sudo nginx
wait
