from python_on_whales import docker
from psycopg2 import connection

class Deployer:
    def __init__(self, conn: connection):
        self.conn = conn
    
    def create_instance(self, lesson_id: str) -> str | None:
        cur = self.conn.cursor()
        cur.execute('SELECT * FROM images WHERE lesson_id=%s', (lesson_id,))
        line = cur.fetchone()
        if not line:
            return None
        
        image = docker.image.inspect(line[0])
        container = docker.container.create(image, publish_all=True)
        container.network_settings.ports





