import sys
import threading

import boto3
from boto3.s3.transfer import TransferConfig


MB = 1024 * 1024
CHUNK_SIZE = 5 * MB

REGION="eu-west-1"
ACCESS_KEY_ID=""
SECRET_ACCESS_KEY=""
BUCKET_NAME=""

class TransferCallback:
    """
    Handle callbacks from the transfer manager.

    The transfer manager periodically calls the __call__ method throughout
    the upload and download process so that it can take action, such as
    displaying progress to the user and collecting data about the transfer.
    """

    def __init__(self, target_size):
        self._target_size = target_size
        self._total_transferred = 0
        self._lock = threading.Lock()
        self.thread_info = {}

    def __call__(self, bytes_transferred):
        """
        The callback method that is called by the transfer manager.

        Display progress during file transfer and collect per-thread transfer
        data. This method can be called by multiple threads, so shared instance
        data is protected by a thread lock.
        """
        thread = threading.current_thread()
        with self._lock:
            self._total_transferred += bytes_transferred
            if thread.ident not in self.thread_info.keys():
                self.thread_info[thread.ident] = bytes_transferred
            else:
                self.thread_info[thread.ident] += bytes_transferred

            target = self._target_size * MB
            sys.stdout.write(
                f"\r{self._total_transferred} of {target} transferred "
                f"({(self._total_transferred / target) * 100:.2f}%)."
            )
            sys.stdout.flush()


def upload_with_chunksize_and_meta(
    s3, local_file_path, bucket_name, object_key, file_size_mb, metadata=None
):
    """
    Upload a file from a local folder to an Amazon S3 bucket, setting a
    multipart chunk size and adding metadata to the Amazon S3 object.

    The multipart chunk size controls the size of the chunks of data that are
    sent in the request. A smaller chunk size typically results in the transfer
    manager using more threads for the upload.

    The metadata is a set of key-value pairs that are stored with the object
    in Amazon S3.
    """
    transfer_callback = TransferCallback(file_size_mb)

    config = TransferConfig(multipart_chunksize=1 * MB)
    extra_args = {"Metadata": metadata} if metadata else None
    s3.Bucket(bucket_name).upload_file(
        local_file_path,
        object_key,
        Config=config,
        ExtraArgs=extra_args,
        Callback=transfer_callback,
    )
    return transfer_callback.thread_info

#=======================
def get_file_size(file_object):
    file_object.seek(0, 2) 
    size = file_object.tell()
    return size / MB

if len(sys.argv) > 1:
    filepath = sys.argv[1]  #first arg
    key = filepath[filepath.rfind("/")+1:]
    metadata = None
    try:
        s3 = boto3.resource("s3", 
            region_name = REGION,
            aws_access_key_id = ACCESS_KEY_ID, 
            aws_secret_access_key = SECRET_ACCESS_KEY
        )
        with open(filepath) as file:
            upload_with_chunksize_and_meta(s3, filepath, BUCKET_NAME, key, get_file_size(file), metadata)
            
    except IOError as e:
        sys.stdout.write("File read error: {}".format(e.strerror))
    except Exception as e:
        sys.stdout.write("Error: {}".format(e.args))
else:
    sys.stdout.write("usage: {} <file path>".format(sys.argv[0]))