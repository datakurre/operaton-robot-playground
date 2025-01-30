from PyPDF2 import PdfReader
from PyPDF2 import PdfWriter
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas


class PDF:
    def create_pdf(self, filename: str, message: str):
        c = canvas.Canvas(filename, pagesize=letter)
        c.drawString(100, 750, message)
        c.save()

    def merge_pdf(self, a: str, b: str, filename: str):
        pdf_writer = PdfWriter()

        for page in PdfReader(a).pages:
            pdf_writer.add_page(page)

        for page in PdfReader(b).pages:
            pdf_writer.add_page(page)

        with open(filename, "wb") as output_pdf:
            pdf_writer.write(output_pdf)
