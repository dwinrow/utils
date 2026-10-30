using PyCall, Conda

Conda.add("pypdf2",channel="conda-forge")
pdf = pyimport("PyPDF2")

# create a PdfFileWriter object
out = pdf.PdfFileWriter()
  
# Open our PDF file with the PdfFileReader
file = pdf.PdfFileReader("C:\\Users\\DWinrow\\Desktop\\API Reference for Application Communication.pdf")
  
# Get number of pages in original file
num = file.numPages
  
# Iterate through every page of the original 
# file and add it to our new file.
for idx in 0:num-1
    
    # Get the page at index idx
    page = file.getPage(idx)
      
    # Add it to the output file
    out.addPage(page)
  
end
# Create a variable password and store 
# our password in it.
page = file.getPage(1)
out.addPage(page)
password = "pass"
  
# Encrypt the new file with the entered password
out.encrypt(password)
  
# Open a new file "myfile_encrypted.pdf"
f = PyCall.open("C:\\Users\\DWinrow\\Desktop\\API Reference for Application Communication_encrypted.pdf","w")
s = ""

# Write our encrypted PDF to this file
out.write(f)

out