#!/bin/bash

set -e

ITOOAOOD_URI='http://aokilab.kyoto-su.ac.jp/documents/IntroductionToOOAOOD/index-j.html'
ITOOAOOD_CHAPTER_URI='http://aokilab.kyoto-su.ac.jp/documents/IntroductionToOOAOOD/chapter1/index-j.html'

script_root="${PWD}"
html_dir="${script_root}/html"
lib_dir="${script_root}/lib"

download() {
    local filename
    local uri
    local d

    echo 'Download Introduction To OOA / OOD'
    mkdir -p "${html_dir}"

    # Frontpage
    cd "${html_dir}"
    filename="${ITOOAOOD_URI/#*\/}"
    echo "${ITOOAOOD_URI}"
    [[ -f "${filename}" ]] || curl --output "${filename}" "${ITOOAOOD_URI}"
    download_images "${ITOOAOOD_URI}"
    cd - > /dev/null

    # Chapters
    for d in $(seq 1 7); do
        mkdir -p "${html_dir}/chapter${d}"
        cd "${html_dir}/chapter${d}"
        uri="${ITOOAOOD_CHAPTER_URI/chapter1/chapter${d}}"
        filename="${uri/#*\/}"
        echo "${uri}"
        [[ -f "${filename}" ]] || curl --output "${filename}" "${uri}"
        download_images "${uri}"
        cd - > /dev/null
    done
}

download_images() {
    local html_uri="${1}"

    local path
    local dirname
    local html_file
    local image_file
    local image_uri

    dirname="${html_uri%\/*}"
    html_file="${html_uri/#*\/}"
    for path in $("${lib_dir}/itooaood-image.rb" "${html_file}"); do
        image_file="${path/#*\/}"
        image_uri="${dirname}/${path}"
        echo "${image_uri}"
        [[ -f "${html_dir}/${image_file}" ]] ||
            curl --output "${html_dir}/${image_file}" "${image_uri}"
    done
}

prepare_temporary_directory() {
    if [[ "${#}" -gt 0 ]]; then
        # Debug
        TMP_DIR="${script_root}/tmp"
        mkdir -p "${TMP_DIR}"
    else
        TMP_DIR=$(mktemp -d '/tmp/itooaood-epub.XXXXXX')
        trap "rm -rf ${TMP_DIR}" exit
    fi
}

compile_all_html() {
    local filename
    local html_files=()
    local i=0

    echo 'Compile all HTML'

    cd "${html_dir}"
    for filename in index-j.html chapter?/index-j.html; do
        html_files[i++]="${filename}"
    done
    "${lib_dir}/itooaood-html.rb" "${ITOOAOOD_URI}" "${html_files[@]}" > "ITOOAOOD.html"
    cd - > /dev/null
}

convert_to_epub() {
    echo 'Convert to EPUB'

    TMP_EPUB_FILE=$(mktemp "${TMP_DIR}/itooaood.epub-XXXXXX")
    cd "${html_dir}"
    pandoc -f html -t epub3 --epub-cover-image="IntroductionToOOAOODFrontPage.jpg" -o "${TMP_EPUB_FILE}" 'ITOOAOOD.html'
    cd - > /dev/null
}

expand_epub() {
    echo 'Expand EPUB'

    TMP_EPUB_DIR=$(mktemp -d "${TMP_DIR}/itooaood.XXXXXX")
    cd "${TMP_EPUB_DIR}"
    unzip -o "${TMP_EPUB_FILE}" > /dev/null
    cd - > /dev/null
}

convert_footnode() {
    echo 'Convert footnote'

    cd "${TMP_EPUB_DIR}"
    for xhtml in ch*.xhtml; do
        mv "${xhtml}" "${xhtml}.orig"
        "${lib_dir}/itooaood-footnote.rb" "${xhtml}.orig" > "${xhtml}"
        rm "${xhtml}.orig"
    done
    cd - > /dev/null
}

compress_epub() {
    echo 'Compress EPUB'

    cd "${TMP_EPUB_DIR}"
    zip -r "${script_root}/itooaood.epub" . > /dev/null
    cd - > /dev/null
}

download "${@}"
prepare_temporary_directory "${@}"
compile_all_html "${@}"
convert_to_epub "${@}"
expand_epub "${@}"
convert_footnode "${@}"
compress_epub "${@}"

