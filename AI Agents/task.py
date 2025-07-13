class ScorePdfTask:
    def __init__(self, ipfs_hash: str):
        self.name = "ScorePdfTask"
        self.description = "Download, summarize, and score PDF"
        self.ipfs_hash = ipfs_hash

    def run(self, agent):
        """Execute the task using the provided agent"""
        file_path = agent.download_pdf(self.ipfs_hash)
        text = agent.extract_text(file_path)
        summary = agent.summarize(text)
        score = agent.score(text)
        return {
            "summary": summary,
            "score": score
        }
