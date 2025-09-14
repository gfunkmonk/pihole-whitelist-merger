#!/bin/bash

set -eo pipefail

# ────────────────────────────────────────────────────────────────
# 🎨 Terminal Colors
# ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ────────────────────────────────────────────────────────────────
# 📁 Paths and Filenames
# ────────────────────────────────────────────────────────────────
workspace="${GITHUB_WORKSPACE:-$(pwd)}"
input_file="$workspace/allowlists.txt"
date_str=$(date -u +'%Y-%m-%d')
output_versioned="$workspace/allowlist_${date_str}.txt"
output_static="$workspace/allowlist.txt"

echo -e "${BLUE}Starting Pi-hole allowlist update at $(date -u)${NC}"
echo -e "${BLUE}Reading allowlist URLs from ${input_file}${NC}"
echo -e "${BLUE}Output will be saved to:${NC}"
echo -e "${BLUE} - ${output_versioned}${NC}"
echo -e "${BLUE} - ${output_static}${NC}"

if [[ ! -f "$input_file" ]]; then
  echo -e "${RED}ERROR: allowlists.txt not found at $input_file${NC}"
  exit 2
fi

temp_domains=$(mktemp)
trap 'rm -f "$temp_domains" /tmp/list.tmp' EXIT

echo -e "${BLUE}Temporary domains file: $temp_domains${NC}"

# ────────────────────────────────────────────────────────────────
# 📥 Download & Parse
# ────────────────────────────────────────────────────────────────
while IFS= read -r url; do
    [[ -z "$url" || "${url:0:1}" == "#" ]] && continue

    echo -e "${YELLOW}Downloading $url ...${NC}"
    if ! curl --retry 3 --retry-delay 5 -sfL "$url" -o /tmp/list.tmp; then
        echo -e "${RED}ERROR: Failed to download $url - skipping${NC}" >&2
        continue
    fi

    if [[ ! -s /tmp/list.tmp ]]; then
        echo -e "${YELLOW}WARNING: Downloaded list is empty for $url - skipping${NC}"
        continue
    fi

    echo -e "${YELLOW}Filtering valid Pi-hole domains from $url ...${NC}"

    if ! grep -Ev '^\s*(#|!|@@|$)' /tmp/list.tmp | \
        sed -E 's/^(0\.0\.0\.0|127\.0\.0\.1|::)\s+//' | \
        sed -E 's/^https?:\/\/([^\/]+).*/\1/' | \
        sed -E 's/[[:space:]]+#.*//' | \
        tr '[:upper:]' '[:lower:]' | \
        grep -E '^[a-z0-9.-]+$' | \
        grep -Ev '(^-|-$|\.\.|--)' | \
        awk 'length($0) >= 3 && length($0) <= 253' | \
        grep -Ev '^([0-9]{1,3}\.){3}[0-9]{1,3}$' >> "$temp_domains"; then
        echo -e "${RED}ERROR: Filtering failed for $url - skipping${NC}"
        continue
    fi

done < "$input_file"

# ────────────────────────────────────────────────────────────────
# 🧹 Sort & Save
# ────────────────────────────────────────────────────────────────
echo -e "${BLUE}Sorting and deduplicating domains...${NC}"

printf "upload.facebook.com" >> "$temp_domains"
printf "creative.ak.fbcdn.net >> "$temp_domains"
printf "external-lhr0-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr1-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr10-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr2-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr3-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr4-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr5-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr6-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr7-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr8-1.xx.fbcdn.net >> "$temp_domains"
printf "external-lhr9-1.xx.fbcdn.net >> "$temp_domains"
printf "fbcdn-creative-a.akamaihd.net >> "$temp_domains"
printf "scontent-lhr3-1.xx.fbcdn.net >> "$temp_domains"
printf "scontent.xx.fbcdn.net >> "$temp_domains"
printf "scontent.fgdl5-1.fna.fbcdn.net >> "$temp_domains"
printf "graph.facebook.com >> "$temp_domains"
printf "b-graph.facebook.com >> "$temp_domains"
printf "connect.facebook.com >> "$temp_domains"
printf "cdn.fbsbx.com >> "$temp_domains"
printf "api.facebook.com >> "$temp_domains"
printf "edge-mqtt.facebook.com >> "$temp_domains"
printf "mqtt.c10r.facebook.com >> "$temp_domains"
printf "portal.fb.com >> "$temp_domains"
printf "star.c10r.facebook.com >> "$temp_domains"
printf "star-mini.c10r.facebook.com >> "$temp_domains"
printf "b-api.facebook.com >> "$temp_domains"
printf "fb.me >> "$temp_domains"
printf "bigzipfiles.facebook.com >> "$temp_domains"
printf "l.facebook.com >> "$temp_domains"
printf "www.facebook.com >> "$temp_domains"
printf "scontent-atl3-1.xx.fbcdn.net >> "$temp_domains"
printf "static.xx.fbcdn.net >> "$temp_domains"
printf "edge-chat.messenger.com >> "$temp_domains"
printf "video.xx.fbcdn.net >> "$temp_domains"
printf "external-ort2-1.xx.fbcdn.net >> "$temp_domains"
printf "scontent-ort2-1.xx.fbcdn.net >> "$temp_domains"
printf "edge-chat.facebook.com >> "$temp_domains"
printf "scontent-mia3-1.xx.fbcdn.net >> "$temp_domains"
printf "web.facebook.com >> "$temp_domains"
printf "rupload.facebook.com >> "$temp_domains"
printf "l.messenger.com" >> "$temp_domains"
printf "android.clients.google.com" >> "$temp_domains"
printf "mtalk.googel.com" >> "$temp_domains"
printf "wa.me" >> "$temp_domains"
printf "dl.dropbox.com" >> "$temp_domains"
printf "dl.dropboxusercontent.com" >> "$temp_domains" 
printf "rover.ebay.com" >> "$temp_domains"
printf "graph.instagram.com" >> "$temp_domains" 
printf "graph.oculus.com" >> "$temp_domains"
printf "giphy.com" >> "$temp_domains"
printf "dl.google.com" >> "$temp_domains" 
printf "goo.gl" >> "$temp_domains"
printf "googlehosted.l.googleusercontent.com" >> "$temp_domains"
printf "play-lh.googleusercontent.com" >> "$temp_domains"
printf "update.nanoav.ru" >> "$temp_domains"
printf "storage.live.com" >> "$temp_domains"
printf "wikipedia.org" >> "$temp_domains"
printf "netflix.com" >> "$temp_domains" 
printf "secure.netflix.com" >> "$temp_domains"
printf "nrdp.prod.cloud.netflix.com" >> "$temp_domains" 
printf "win10.prod.http1.netflix.com" >> "$temp_domains"
printf "dynupdate.no-ip.com" >> "$temp_domains"
printf "lh3.googleusercontent.com" >> "$temp_domains"
printf "play.spotify.edgekey.net" >> "$temp_domains"
printf "open.spotify.com" >> "$temp_domains"
printf "t.co" >> "$temp_domains"
printf "twimg.com" >> "$temp_domains"
printf "bit.ly" >> "$temp_domains"
printf "tinyurl.com" >> "$temp_domains"
printf "www.adf.ly" >> "$temp_domains"

sort -u "$temp_domains" > "$output_versioned"
cp "$output_versioned" "$output_static"

count=$(wc -l < "$output_static")
echo -e "${GREEN}Allowlist update complete: $count domains written.${NC}"
echo -e "${GREEN}Static Pi-hole URL output available at: ${output_static}${NC}"

# ────────────────────────────────────────────────────────────────
# 🚀 Auto Commit (optional for GitHub Actions)
# ────────────────────────────────────────────────────────────────
if [[ -n "$GITHUB_ACTIONS" ]]; then
  echo -e "${BLUE}Committing new allowlists to GitHub...${NC}"
  git config --global user.email "bot@example.com"
  git config --global user.name "Allowlist Bot"

  git add "$output_static" "$output_versioned"

  if git diff --cached --quiet; then
    echo -e "${YELLOW}No changes to commit.${NC}"
  else
    git commit -m "Update allowlist on $date_str"
    git push --force
    echo -e "${GREEN}Allowlists committed and pushed.${NC}"
  fi
fi
