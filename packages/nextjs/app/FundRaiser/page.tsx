"use client"
import React, { useState } from 'react';

const UploadAndAnalyzePDF: React.FC = () => {
    const [file, setFile] = useState<File | null>(null);
    const [ipfsHash, setIpfsHash] = useState('');
    const [copied, setCopied] = useState(false);
    const [inputHash, setInputHash] = useState('');
    const [loading, setLoading] = useState(false);
    const [analysisResult, setAnalysisResult] = useState<any>(null);
    const [error, setError] = useState('');

    const PINATA_JWT = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiIxNGI4ZTIyMy02MmJjLTQ3OTItYTk1OS02NTJlMTA4ZTIyODkiLCJlbWFpbCI6InI1NTVzaWRAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInBpbl9wb2xpY3kiOnsicmVnaW9ucyI6W3siZGVzaXJlZFJlcGxpY2F0aW9uQ291bnQiOjEsImlkIjoiRlJBMSJ9LHsiZGVzaXJlZFJlcGxpY2F0aW9uQ291bnQiOjEsImlkIjoiTllDMSJ9XSwidmVyc2lvbiI6MX0sIm1mYV9lbmFibGVkIjpmYWxzZSwic3RhdHVzIjoiQUNUSVZFIn0sImF1dGhlbnRpY2F0aW9uVHlwZSI6InNjb3BlZEtleSIsInNjb3BlZEtleUtleSI6IjZkMWViMjdmM2E5YTc3ZmVhYTFjIiwic2NvcGVkS2V5U2VjcmV0IjoiNjQ2NGNhNjM1OTE4Y2MwNTUzMWNjYmI2YTBmMWEzMjA0MDRkNzdjNjdlYWVkZjc3YjNjNTQ1MGRkM2I0YWQ5OCIsImV4cCI6MTc4Mzg1NzcyMX0.xIyaH2dSVjx75UWdTtbXYLgnLeSY5zEJyRA7oAGFlU0'; // Replace with your actual JWT

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files.length > 0) {
            setFile(e.target.files[0]);
        }
    };

    const handleUpload = async () => {
        if (!file) return;
        setLoading(true);
        setError('');
        setIpfsHash('');
        setAnalysisResult(null);

        const formData = new FormData();
        formData.append('file', file);

        try {
            const res = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
                method: 'POST',
                headers: {
                    Authorization: PINATA_JWT,
                },
                body: formData,
            });

            const data = await res.json();

            if (res.ok) {
                setIpfsHash(data.IpfsHash);
                setInputHash(data.IpfsHash);
            } else {
                setError('Failed to upload to Pinata');
            }
        } catch (err: any) {
            setError('Upload error: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleCopy = () => {
        navigator.clipboard.writeText(ipfsHash);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    const handleAnalyze = async () => {
        if (!inputHash) return;
        setLoading(true);
        setError('');
        setAnalysisResult(null);

        try {
            const res = await fetch('http://localhost:5000/analyze', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ipfs_hash: inputHash }),
            });

            const data = await res.json();

            if (res.ok) {
                setAnalysisResult(data);
            } else {
                setError('AI Analysis failed');
            }
        } catch (err: any) {
            setError('Request error: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="max-w-xl mx-auto p-6 space-y-6">
            <h1 className="text-2xl font-bold">PDF Upload & AI Report Generator</h1>

            {/* Upload Section */}
            <div className="space-y-2">
                <input type="file" accept="application/pdf" onChange={handleFileChange} />
                <button
                    onClick={handleUpload}
                    className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
                    disabled={!file || loading}
                >
                    {loading ? 'Uploading...' : 'Upload to Pinata'}
                </button>
            </div>

            {/* IPFS Hash Display */}
            {ipfsHash && (
                <div className="bg-gray-100 border border-gray-300 p-3 rounded flex items-center justify-between">
                    <span className="break-all text-sm font-mono">{ipfsHash}</span>
                    <button
                        onClick={handleCopy}
                        className="ml-4 bg-gray-200 px-2 py-1 text-xs rounded hover:bg-gray-300"
                    >
                        {copied ? 'Copied!' : 'Copy'}
                    </button>
                </div>
            )}

            {/* Hash Input & Submit */}
            <div className="space-y-2">
                <label htmlFor="ipfsInput" className="block font-medium">
                    Paste IPFS Hash to generate AI report:
                </label>
                <input
                    id="ipfsInput"
                    type="text"
                    value={inputHash}
                    onChange={(e) => setInputHash(e.target.value)}
                    placeholder="Qm..."
                    className="w-full border border-gray-300 rounded p-2"
                />
                <button
                    onClick={handleAnalyze}
                    className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:opacity-50"
                    disabled={!inputHash || loading}
                >
                    {loading ? 'Analyzing...' : 'Submit to AI'}
                </button>
            </div>

            {/* Loading or Result */}
            {loading && (
                <p className="text-gray-600 text-sm">AI is analyzing the document, please wait...</p>
            )}

            {error && <p className="text-red-600">{error}</p>}

            {analysisResult && (
                <div className="mt-4 border border-green-400 bg-green-50 p-4 rounded space-y-2">
                    <h3 className="text-lg font-semibold text-green-800">AI Analysis Result</h3>
                    <p><strong>Score:</strong> {analysisResult.score}/10</p>
                    <p><strong>Message:</strong> {analysisResult.message}</p>
                    <p><strong>Summary:</strong> {analysisResult.summary}</p>
                    <p className="text-xs text-gray-500">Analyzed on: {new Date(analysisResult.timestamp).toLocaleString()}</p>
                </div>
            )}
        </div>
    );
};

export default UploadAndAnalyzePDF;
