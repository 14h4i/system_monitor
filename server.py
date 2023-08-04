# server.py

import asyncio
import logging
import psutil
import websockets


async def send_info(websocket, path):
    while True:
        data = await websocket.recv()
        if data == 'get_ram':
            ram_used_gb = psutil.virtual_memory().used / (1024**3)
            await websocket.send(f"ram,{ram_used_gb:.2f}")
        elif data == 'get_cpu':
            cpu_percentage = psutil.cpu_percent()
            await websocket.send(f"cpu,{cpu_percentage:.2f}")
        elif data == 'realtime':
            while True:
                ram_used_gb = psutil.virtual_memory().used / (1024**3)
                cpu_percentage = psutil.cpu_percent()
                message = f"{ram_used_gb:.2f},{cpu_percentage:.2f}"
                await websocket.send(message)
                await asyncio.sleep(1)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

start_server = websockets.serve(send_info, "localhost", 8765)
logger.info("Server is running. Listening for connections...")

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
