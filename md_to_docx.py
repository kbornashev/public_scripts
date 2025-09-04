import os
import pypandoc
def find_md_files(directory):
    md_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".md"):
                md_files.append(os.path.join(root, file))
    return md_files
def convert_md_to_pdf(md_file, output_dir):
    output_file = os.path.join(output_dir, os.path.splitext(os.path.basename(md_file))[0] + '.pdf')
    pypandoc.convert_file(md_file, 'pdf', outputfile=output_file)
def convert_md_to_docx(md_file, output_dir):
    output_file = os.path.join(output_dir, os.path.splitext(os.path.basename(md_file))[0] + '.docx')
    pypandoc.convert_file(md_file, 'docx', outputfile=output_file)
def main(directory, output_dir, format='pdf'):
    md_files = find_md_files(directory)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for md_file in md_files:
        if format == 'pdf':
            convert_md_to_pdf(md_file, output_dir)
        elif format == 'docx':
            convert_md_to_docx(md_file, output_dir)
        else:
            print(f"Unsupported format: {format}")
if __name__ == "__main__":
    input_directory = "/home/bo/om/distr-docs/distr-docs"
    output_directory = "/home/bo/om/distr-docs/docx"
    output_format = "docx"  # можно поменять на 'docx'
    main(input_directory, output_directory, output_format)
