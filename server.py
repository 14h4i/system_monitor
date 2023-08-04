# server.py

import asyncio
import psutil
import websockets

async def send_info(websocket, path):
    while True:
        data = await websocket.recv()
        if data == 'get_ram':
            ram_used_gb = psutil.virtual_memory().used / (1024**3)  # Đổi sang GB
            await websocket.send(f"ram,{ram_used_gb:.2f}")
        elif data == 'get_cpu':
            cpu_percentage = psutil.cpu_percent()
            await websocket.send(f"cpu,{cpu_percentage:.2f}")
        elif data == 'realtime':
            while True:
                ram_used_gb = psutil.virtual_memory().used / (1024**3)  # Đổi sang GB
                cpu_percentage = psutil.cpu_percent()
                message = f"{ram_used_gb:.2f},{cpu_percentage:.2f}"  # Lấy 2 chữ số thập phân
                await websocket.send(message)
                await asyncio.sleep(1)

start_server = websockets.serve(send_info, "localhost", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
