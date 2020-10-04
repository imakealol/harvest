#!/bin/sh

# 12/09/2020 (Argentino Trombin - Almaviva S.p.A)
# Modulo per il caricamento e lo scarico di files verso lo Storage S3 della BNCF


function check_download_integrity()
{

	file_to_download_to=$1
	file_to_download_to_md5=$2

	echo "Checking download integrity for " $file_to_download_to


	# Controllare che MD5 scaricato da S3 corrisonda ad MD5 generato dlocalmente dopo il download
	awk_command='
	    BEGIN    {
	        FS=" "; 
	    }
	 
	    FILENAME == ARGV[1] {
	        md5_AR[$1] = $1;
	        print "->S3    md5 " $1
	        next;
	    }
	    {
	    if ($1 in md5_AR)
	        {
	        print "->CHECK md5 " $1 " matches " 
	        next
	        }
	    else
	        {
	        print "CHECK md5 " $1 " DOES NOT match"
	        }
	    }' 

	# Create md5 checksum on downloaded file
	md5sum $file_to_download_to > $file_to_download_to_md5_check 

	# Check downloaded md5 against generated md5
	awk "$awk_command" $file_to_download_to_md5 $file_to_download_to_md5_check

} # end check_download_integrity








function dowbnload_warcs_from_s3()
{
	echo "--------------------------------"
	echo "Downloading warcs.gz from S3 storage"
	echo "warcs.gz will be downloaded with accociated .md5 file in same folder"

echo "TODO take in input download_dir (da dichiarare nei file di config) e s3_path_filename )"	


  #    while IFS='|' read -r -a array line
  #    do
  #          line=${array[0]}

  #         if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
  #           break
  #         fi

  #          # se riga comentata o vuota skip
  #          if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
  #                continue
  #           fi

  #       local istituto=$(echo "${array[1]}" | cut -f 1 -d '.')
  #      	local warc_filename=$harvest_date_materiale"_"$istituto".warc.gz"
  #      	local file_to_download_to="/home/argentino/Downloads/"$warc_filename
  #      	local md5_file_to_download_to=$file_to_download_to".md5"
  #      	local s3_path_filename=""

		# if [ $ambiente == "sviluppo" ]; then
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/sviluppo_"$warc_filename
		# elif [ $ambiente == "collaudo" ]; then 
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/collaudo_"$warc_filename
		# elif [ $ambiente == "esercizio" ] || [ $ambiente == "nyovo_esercizio" ]; then
		# 	# Esercizio
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/"$warc_filename
		# else
		# 		echo "ambiente '"$ambiente"' sconosciuto. STOP'"
		# 		return
		# fi

  #      	echo "istituto="$istituto
  #      	echo "ambiente="$ambiente
  #      	echo " warc_filename="$warc_filename
  #      	echo " harvest_date_materiale="$harvest_date_materiale
  #      	echo " file_to_download_to="$file_to_download_to
  #      	echo " md5_file_to_download_to="$md5_file_to_download_to
  #      	echo " s3_path_filename="$s3_path_filename


		# java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		#     -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		#     action=download \
		#     s3_keyname=$s3_path_filename \
		#     file_to_download_to=$file_to_download_to \


		# check_download_integrity $file_to_download_to $md5_file_to_download_to

  #    done < "$repositories_file"

} # End dowbnload_warcs_from_s3


function upload_warcs_to_s3()
{
	echo "--------------------------------"
	echo "Uploading warcs.gz to S3 storage"
	echo "warcs.gz must have accociated .md5 file in same folder"

     while IFS='|' read -r -a array line
     do
           line=${array[0]}

          if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
            break
          fi

           # se riga comentata o vuota skip
           if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
                 continue
            fi

        local istituto=$(echo "${array[1]}" | cut -f 1 -d '.')

       	# file_to_upload=$warcs_dir"/"$harvest_date_materiale"_"$istituto".warc.gz"
       	local warc_filename=$harvest_date_materiale"_"$istituto".warc.gz"
       	local file_to_upload=$dest_warcs_dir"/"$warc_filename
       	local md5_file_to_upload=$file_to_upload".md5"
       	local s3_path_filename=""

       	echo "istituto="$istituto
       	echo "ambiente="$ambiente
       	echo " warc_filename="$warc_filename
       	echo " harvest_date_materiale="$harvest_date_materiale
       	echo " file_to_upload="$file_to_upload
       	echo " md5_file_to_upload="$md5_file_to_upload


		if [ $ambiente == "sviluppo" ]; then
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/sviluppo_"$warc_filename
		elif [ $ambiente == "collaudo" ]; then 
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/collaudo_"$warc_filename
		elif [ $ambiente == "esercizio" ] || [ $ambiente == "nuovo_esercizio" ]; then
			# Esercizio
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/"$warc_filename
		else
				echo "ambiente '"$ambiente"' sconosciuto. STOP'"
				exit
		fi

       	echo " s3_path_filename="$s3_path_filename




       	# Check if files to upload exist
	    if [ ! -f $file_to_upload ]; then
	        "Missing file to upload: "$file_to_upload" SKIPPING ...."
	        continue;
	    fi
	    if [ ! -f $md5_file_to_upload ]; then
	        "Missing md5 file to upload: "$md5_file_to_upload" SKIPPING ...."
	        continue;
	    fi

	    s3log_filename=$s3_dir"/"$harvest_date_materiale"."$istituto".upload.log"
echo "s3log_filename = " $s3log_filename

		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename



     done < "$repositories_file"
} # End  upload_warcs_to_s3





function upload_split_warcs_to_s3()
{
	istituto=$1

	echo "--------------------------------"
	echo "Uploading split warcs.gz to S3 storage"
	echo "warcs.gz must have accociated .md5 file in same folder"

	echo "istituto="$istituto

	split_warcs_dir=$dest_warcs_dir"/split_dir"

	echo "split_warcs_dir="$split_warcs_dir

    for filename in $split_warcs_dir/*.gz.??; do
        if [ -s "$filename" ]
        then
# echo "filename="$filename
            # fname= basename $filename .seeds
            fname=$(basename -- "$filename")
            # extension="${fname##*.}"
            # fname="${fname%.*}"
# echo "------>fname="$fname

       	local warc_filename=$fname
       	local file_to_upload=$filename
       	local md5_file_to_upload=$file_to_upload".md5"
       	local s3_path_filename=""

		if [ $ambiente == "sviluppo" ]; then
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/sviluppo_"$warc_filename
		elif [ $ambiente == "collaudo" ]; then 
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/collaudo_"$warc_filename
		elif [ $ambiente == "esercizio" ] || [ $ambiente == "nuovo_esercizio" ]; then
			# Esercizio
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/"$warc_filename
		else
				echo "ambiente '"$ambiente"' sconosciuto. STOP'"
				exit
		fi

# echo "warc_filename="$warc_filename
# echo "file_to_upload="$file_to_upload
# echo "md5_file_to_upload="$md5_file_to_upload
echo " s3_path_filename="$s3_path_filename


	    if [ ! -f $md5_file_to_upload ]; then
	        "Missing md5 file to upload: "$md5_file_to_upload" SKIPPING ...."
	        continue;
	    fi

	    s3log_filename=$s3_dir"/"$warc_filename".upload.log"
echo "s3log_filename = " $s3log_filename

		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename

        else
        	echo "$filename is empty."
                # do something as file is empty
        fi
    done


} # End  upload_split_warcs_to_s3



