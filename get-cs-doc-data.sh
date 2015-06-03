#!/usr/bin/env bash

#Author: River

createNode(){
    SRC_File=$1
    Target_File=$2
    File_ID=$3
    File_Type=$4
    File_Mime=$5
    SRC_File_Name=$6

    echo 'all paras are : '${*}

    tag_start(){
        echo '<'${*}'>' >> $Target_File
    }

    tag_end(){
        echo '</'${*}'>'  >> $Target_File
    }

    tag_start_without_new_line(){
        echo -n '<'${*}'>'  >> $Target_File
    }

    put_raw_text(){
        echo -n ${*}  >> $Target_File
    }

    convert_file_with_base64(){
        cat $SRC_File | Base64 | while read CONTENT; do
            echo -n $CONTENT >> $Target_File
        done
    }

    tag_start 'cac:AdditionalDocumentReference'

        tag_start_without_new_line 'cbc:ID'
        put_raw_text $File_ID
        tag_end 'cbc:ID'

        tag_start_without_new_line 'cbc:DocumentTypeCode listID="urn:tradeshift.com:api:1.0:documenttypecode"'
        put_raw_text $File_Type
        tag_end 'cbc:DocumentTypeCode'

        tag_start 'cac:Attachment'

        tag_start_without_new_line 'cbc:EmbeddedDocumentBinaryObject encodingCode="Base64" filename="'$SRC_File_Name'" mimeCode="'$File_Mime'"'
        convert_file_with_base64
        tag_end 'cbc:EmbeddedDocumentBinaryObject'

        tag_end 'cac:Attachment'


    tag_end 'cac:AdditionalDocumentReference'
}

#createNode invoice.pdf out.xml 1 sourcedocument application/pdf sourcedocument.

psql \
-X \
-h localhost \
-U porta \
-c "select externalid, dmd.documentid from documentmetadata dmd join documents d on dmd.documentid=d.uuid join documentcontent dc on dc.documentid=d.uuid where d.state='LOCKED' and d.deleted=false and dmd.key='AP_DOCUMENT_STATE' and dmd.value='DISPATCHED' and dc.original=true " \
--single-transaction \
--no-align \
-t \
--field-separator " " \
--quiet \
porta | while read -a Record ; do
externalid=${Record[0]}
documentid=${Record[1]}
curl -v -o./$documentid.xml http://localhost:8098/riak/documents/$externalid
    psql \
    -X \
    -h localhost \
    -U porta \
    -c "select externalid, dmd.documentid from documentmetadata dmd join documents d on dmd.documentid=d.uuid join documentcontent dc on dc.documentid=d.uuid where d.state='LOCKED' and d.deleted=false and dmd.key='AP_DOCUMENT_STATE' and dmd.value='DISPATCHED' and dc.original=true " \
    --single-transaction \
    --no-align \
    -t \
    --field-separator " " \
    --quiet \
    porta | while read -a Record ; do
    externalid=${Record[0]}
    documentid=${Record[1]}
    curl -v -o./$documentid.xml http://localhost:8098/riak/documents/$externalid

    done

done