#!/bin/bash
echo "-> CXleanup hunspell-ES..."
# Remove unwanted Spanish dictionaries, keep only es_ES and es_CO

for lang in es_ANY es_AR es_BO es_CL es_CR es_CU es_DO es_EC es_GT es_HN es_MX es_NI es_PA es_PR es_PY es_PE es_SV es_UY es_VE; do
    sudo rm -f /usr/share/hunspell/${lang}.*
done
echo "Cleaned up unnecessary Spanish dictionaries. Remaining:"
ls /usr/share/hunspell/ | grep es
