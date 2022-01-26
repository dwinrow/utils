from PyPDF2 import PdfFileWriter, PdfFileReader
import os
import pyodbc
import re
import argparse

def encrypt_pdf(input_file, user_pass, output_file):

    pdf_in_file = open(input_file,'rb')

    inputpdf = PdfFileReader(pdf_in_file)
    pages_no = inputpdf.numPages

    output = PdfFileWriter()
    for i in range(pages_no):
        output.addPage(inputpdf.getPage(i))

    output.encrypt(user_pass)
    with open(output_file, "wb") as outputStream:
        output.write(outputStream)

    pdf_in_file.close()
    outputStream.close()

def getdigits(instr):
    findobj = re.findall(r'\d\d\d\d\d\d', instr)
    if len(findobj) > 0:
        return int(findobj[0])
    else:
        return 0

def encrypt_bc_pdf_folder(directory):
    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        r'DBQ=F:\Boal & Co\Pensions\Balley Chashtal\BC Administration.mdb;'
        )
    cnxn = pyodbc.connect(conn_str)
    crsr = cnxn.cursor()
    directory_out = os.path.join(directory,"Secure")
    if not os.path.exists(directory_out):
        os.mkdir(directory_out)

    dir_contents = os.listdir(directory)  
    memIDs = list(map(getdigits,dir_contents))

    for i in range(len(memIDs)):
        memID = memIDs[i]
        file = dir_contents[i]
        if memID > 0 and file.endswith(".pdf"):
            rtn = crsr.execute("SELECT DateofBirth FROM Client WHERE MemberId = ?", memID).fetchone()
            encrypt_pdf(os.path.join(directory,file), rtn[0].strftime("%d%m%Y"), os.path.join(directory_out,file))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_directory', required=True,
                        help='Input pdf file')
    args = parser.parse_args()
    encrypt_bc_pdf_folder(args.input_directory)
 
if __name__ == "__main__":
    main()