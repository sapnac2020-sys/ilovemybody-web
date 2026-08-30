from __future__ import annotations

import io
import re
from dataclasses import dataclass
from datetime import datetime
from typing import Iterable

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload


SCOPES = ["https://www.googleapis.com/auth/drive.readonly"]


@dataclass(frozen=True)
class DriveFile:
    id: str
    name: str
    modified_time: datetime | None
    size: int


class DriveReader:
    def __init__(self, key_file: str):
        creds = service_account.Credentials.from_service_account_file(key_file, scopes=SCOPES)
        self.service = build("drive", "v3", credentials=creds, cache_discovery=False)

    @staticmethod
    def discovery_query(folder_id: str) -> str:
        if folder_id == "sharedWithMe":
            return "sharedWithMe = true and trashed = false"
        if not re.fullmatch(r"[A-Za-z0-9_-]+", folder_id):
            raise ValueError("Invalid Google Drive folder ID")
        return f"'{folder_id}' in parents and trashed = false"

    def list_excel(self, folder_id: str) -> Iterable[DriveFile]:
        token = None
        query = self.discovery_query(folder_id)
        while True:
            response = self.service.files().list(
                q=query, fields="nextPageToken,files(id,name,modifiedTime,size,mimeType)",
                pageToken=token, pageSize=1000, supportsAllDrives=True,
                includeItemsFromAllDrives=True,
            ).execute()
            for item in response.get("files", []):
                if item["name"].lower().endswith((".xlsx", ".xlsm")):
                    stamp = item.get("modifiedTime")
                    yield DriveFile(item["id"], item["name"], datetime.fromisoformat(stamp.replace("Z", "+00:00")) if stamp else None, int(item.get("size", 0)))
            token = response.get("nextPageToken")
            if not token:
                break

    def download(self, file_id: str) -> bytes:
        out = io.BytesIO()
        downloader = MediaIoBaseDownload(out, self.service.files().get_media(fileId=file_id, supportsAllDrives=True))
        done = False
        while not done:
            _, done = downloader.next_chunk()
        return out.getvalue()
