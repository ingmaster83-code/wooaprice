#!/usr/bin/env python3
"""
fetch_goodprice.py - 행정안전부_착한가격업소 현황 CSV 다운로드
data.go.kr 파일데이터 다운로드 (publicDataPk=3045247)

사용법:
  python scripts/fetch_goodprice.py
"""
import sys
from pathlib import Path
import requests

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).parent.parent
OUT_CSV = ROOT / "_rawdata" / "goodprice_raw.csv"

# atchFileId는 data.go.kr 상세페이지에서 다운로드 클릭 시 발급되는 값이라 시간이 지나면
# 바뀔 수 있음 — 재수집 실패시 https://www.data.go.kr/data/3045247/fileData.do 에서
# 다운로드 버튼 클릭 네트워크 요청을 다시 캡처해서 atchFileId 갱신할 것.
ATCH_FILE_ID = "FILE_000000003681743"
FILE_DETAIL_SN = "1"


def main():
    url = "https://www.data.go.kr/cmm/cmm/fileDownload.do"
    params = {"atchFileId": ATCH_FILE_ID, "fileDetailSn": FILE_DETAIL_SN}
    r = requests.get(url, params=params, headers={"User-Agent": "Mozilla/5.0"}, timeout=60)
    r.raise_for_status()

    if len(r.content) < 100_000:
        raise SystemExit(
            f"다운로드 실패로 추정 — 응답 크기가 너무 작음 ({len(r.content)} bytes). "
            "atchFileId가 만료됐을 수 있음 — data.go.kr에서 다시 캡처할 것."
        )

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    OUT_CSV.write_bytes(r.content)
    print(f"다운로드 완료: {OUT_CSV} ({len(r.content):,} bytes)")


if __name__ == "__main__":
    main()
