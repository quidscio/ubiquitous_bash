# Temporary trial and testing for chunking 

_experiment() {
    _start
    echo happy > "$safeTmp"/file.txt
    cat "$safeTmp"/file.txt
    _stop
}


# test-chunking3: create a file, chunk it, upload/download, verify, and reassemble
# Params:
#   $1 = filesize in GB (default: 0.9)
#   $2 = chunksize in GB (default: 0.25)
_test-chunking3() {
    _start 
    local functionEntryPWD="$PWD"
    local filesizeGB="$1"
    local chunksizeGB="$2"
    [[ "$filesizeGB" == "" ]] && filesizeGB="0.9"
    [[ "$chunksizeGB" == "" ]] && chunksizeGB="0.25"

    _messagePlain_nominal "== test-chunking3 filesize: ${filesizeGB}GB, chunksize: ${chunksizeGB}GB" 

    local filesizeBytes chunksizeBytes
    filesizeBytes="$(awk -v g="$filesizeGB" 'BEGIN{printf "%.0f", g*1024*1024*1024}')" || return 1
    chunksizeBytes="$(awk -v g="$chunksizeGB" 'BEGIN{printf "%.0f", g*1024*1024*1024}')" || return 1
    # Guardrails
    [[ "$chunksizeBytes" -le 0 ]] && { echo "bad: chunksizeBytes<=0"; return 1; }
    [[ "$filesizeBytes" -le 0 ]] && { echo "bad: filesizeBytes<=0"; return 1; }
    [[ "$chunksizeBytes" -gt "$filesizeBytes" ]] && chunksizeBytes="$filesizeBytes"

    # Workspace
    local uid
    if type -t _uid > /dev/null 2>&1; then uid="$(_uid 10)"; else uid="$(date +%s)"; fi
    local root="${scriptLocal:-$PWD}/test-chunking3-${uid}"
    local work="$root/work"
    local down="$root/download"
    mkdir -p "$work" "$down" || return 1
    cd "$work" || return 1

    local base="testfileimage.bin"
    local manifest="$work/${base}.manifest.txt"

    # Create file
    # Prefer truncate (fast/sparse), fallback to dd
    if type -p truncate > /dev/null 2>&1; then
        truncate -s "$filesizeBytes" "$base"
    else
        local countMiB
        countMiB="$(awk -v b="$filesizeBytes" 'BEGIN{printf "%d", b/1048576}')" || return 1
        dd if=/dev/zero of="$base" bs=1M count="$countMiB" status=none
    fi

    # Original hash (sha256) and size
    local sha_cmd
    if type -p sha256sum > /dev/null 2>&1; then
        sha_cmd="sha256sum"
    else
        sha_cmd="openssl dgst -sha256 | awk '{print \$2}'"
    fi
    local origSize origHash
    origSize="$(stat -c%s "$base" 2>/dev/null || wc -c < "$base")"
    if [[ "$sha_cmd" == "sha256sum" ]]; then
        origHash="$(sha256sum "$base" | awk '{print $1}')"
    else
        origHash="$(cat "$base" | eval $sha_cmd)"
    fi

    {
        echo "# test-chunking3 manifest"
        echo "base=$base"
        echo "filesize_bytes=$origSize"
        echo "sha256_base=$origHash"
        echo "chunksize_bytes=$chunksizeBytes"
        echo "datetime=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo
        echo "part,bytes,sha256"
    } > "$manifest"

    # Split into parts (tail+truncate pattern used by ubDistBuild)
    _test-chunking3_split-tail "$base" "$chunksizeBytes" || { echo "fail: split"; return 1; }

    # Hash each part
    local p sz h
    for p in ${base}.part??; do
        [[ ! -e "$p" ]] && continue
        sz="$(stat -c%s "$p" 2>/dev/null || wc -c < "$p")"
        if [[ "$sha_cmd" == "sha256sum" ]]; then
            h="$(sha256sum "$p" | awk '{print $1}')"
        else
            h="$(cat "$p" | eval $sha_cmd)"
        fi
        echo "$(basename "$p"),$sz,$h" >> "$manifest"
    done

    # Upload all parts + manifest via rclone (limited) if configured
    local remote="${UB_CHUNK_REMOTE:-distLLC_build_ubDistBuild:}"
    local remotePath="${UB_CHUNK_REMOTE_PATH:-test-chunking3/${uid}}"
    local uploaded="false"
    if type -t _rclone_limited > /dev/null 2>&1; then
        _rclone_limited --progress copy "$work" "${remote}${remotePath}" && uploaded="true"
    else
        echo "note: _rclone_limited not available; skipping upload/download roundtrip."
    fi

    # If uploaded, download to fresh dir
    if [[ "$uploaded" == "true" ]]; then
        cd "$down" || return 1
        _rclone_limited --progress copy "${remote}${remotePath}" "$down" || return 1

        # Verify each part vs manifest
        local manifestDL="$down/$(basename "$manifest")"
        if [[ ! -e "$manifestDL" ]]; then cp -a "$manifest" "$manifestDL"; fi
        local failures=0 passes=0
        while IFS=, read -r fname bytes hash; do
            [[ "$fname" == "part" ]] && continue
            [[ "$fname" == "" ]] && continue
            local f="$down/$fname"
            if [[ -e "$f" ]]; then
                local b h2
                b="$(stat -c%s "$f" 2>/dev/null || wc -c < "$f")"
                if [[ "$sha_cmd" == "sha256sum" ]]; then
                    h2="$(sha256sum "$f" | awk '{print $1}')"
                else
                    h2="$(cat "$f" | eval $sha_cmd)"
                fi
                if [[ "$b" == "$bytes" ]] && [[ "$h2" == "$hash" ]]; then
                    echo "part OK: $fname"
                    passes=$((passes+1))
                else
                    echo "part MISMATCH: $fname (bytes $b vs $bytes, hash $h2 vs $hash)"
                    failures=$((failures+1))
                fi
            else
                echo "part MISSING: $fname"
                failures=$((failures+1))
            fi
        done < <(grep -E '^[^#].*\.part[0-9]{2},' "$manifestDL")

        # Reassemble by appending parts in reverse numeric order
        _test-chunking3_join "$down" "$base" || return 1

        # Verify assembled vs original hash
        local reasm="$down/$base"
        local reasmHash
        if [[ "$sha_cmd" == "sha256sum" ]]; then
            reasmHash="$(sha256sum "$reasm" | awk '{print $1}')"
        else
            reasmHash="$(cat "$reasm" | eval $sha_cmd)"
        fi

        if [[ "$reasmHash" == "$origHash" ]] && [[ "$failures" -eq 0 ]]; then
            echo "success match"
        else
            echo "failure mismatch"
        fi
    else
        # Local-only join + verify (no upload/download)
        _test-chunking3_join "$work" "$base" || return 1
        local reasm="$work/$base"
        local reasmHash
        if [[ "$sha_cmd" == "sha256sum" ]]; then
            reasmHash="$(sha256sum "$reasm" | awk '{print $1}')"
        else
            reasmHash="$(cat "$reasm" | eval $sha_cmd)"
        fi
        if [[ "$reasmHash" == "$origHash" ]]; then
            echo "success match (local-only)"
        else
            echo "failure mismatch (local-only)"
        fi
    fi

    cd "$functionEntryPWD" || return 1
    #return 0
    _stop 
}

# Internal: split using tail+truncate, parameterized chunk size (bytes)
_test-chunking3_split-tail() {
    local inputFile="$1"
    local chunkSize="$2"
    local i=0
    while [[ -e "$inputFile" ]] && [[ -s "$inputFile" ]]; do
        local part="$(printf "%s.part%02d" "$inputFile" "$i")"
        # tail -c returns the whole file if it's smaller than chunkSize
        tail -c "$chunkSize" "$inputFile" > "$part"
        local fileSize
        fileSize="$(stat -c%s "$inputFile" 2>/dev/null || wc -c < "$inputFile")"
        if [[ "$fileSize" -le "$chunkSize" ]]; then
            rm -f "$inputFile"
            break
        else
            truncate -s -"$chunkSize" "$inputFile"
        fi
        i=$((i+1))
        # safety bound
        [[ "$i" -gt 99 ]] && break
    done
}

# Internal: join parts named $base.partNN into $dir/$base (reverse order append)
_test-chunking3_join() {
    local dir="$1"
    local base="$2"
    local out="$dir/$base"
    rm -f "$out" 2>/dev/null
    local parts
    IFS=$'\n' read -r -d '' -a parts < <(cd "$dir" && ls -1 "${base}.part"?? 2>/dev/null | sort -r && printf '\0')
    local p
    for p in "${parts[@]}"; do
        # consistent with ubDistBuild join: dd append with 1M blocks
        dd if="$dir/$p" bs=1M status=none >> "$out"
    done
    [[ -e "$out" ]]
}
