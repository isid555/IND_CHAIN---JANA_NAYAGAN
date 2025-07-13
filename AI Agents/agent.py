import tools

class PdfScorerAgent:
    def __init__(self):
        self.name = "PdfScorerAgent"
        self.description = "Agent that scores a PDF from IPFS"

    def run(self, task):
        """Execute the given task"""
        return task.run(self)
    
    def download_pdf(self, ipfs_hash):
        """Download PDF from IPFS"""
        return tools.download_pdf_from_ipfs(ipfs_hash)
    
    def extract_text(self, file_path):
        """Extract text from PDF"""
        return tools.extract_text_from_pdf(file_path)
    
    def summarize(self, text):
        """Summarize text"""
        return tools.summarize_text(text)
    
    def score(self, text):
        """Score PDF content"""
        return tools.score_pdf_content(text)
