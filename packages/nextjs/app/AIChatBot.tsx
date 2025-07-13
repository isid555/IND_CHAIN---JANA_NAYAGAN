"use client";
import React, { useState } from "react";

const AIChatBot: React.FC = () => {
    const [showChat, setShowChat] = useState(false);
    const [chatHistory, setChatHistory] = useState<
        { prompt: string; reply: string; timestamp: string }[]
    >([]);
    const [userPrompt, setUserPrompt] = useState("");
    const [chatLoading, setChatLoading] = useState(false);
    const [chatError, setChatError] = useState("");

    const handleSendMessage = async () => {
        if (!userPrompt.trim()) return;
        setChatLoading(true);
        setChatError("");

        try {
            const res = await fetch("http://localhost:5000/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ prompt: userPrompt }),
            });

            const data = await res.json();

            if (res.ok) {
                setChatHistory((prev) => [
                    ...prev,
                    {
                        prompt: userPrompt,
                        reply: data.reply,
                        timestamp: data.timestamp,
                    },
                ]);
                setUserPrompt("");
            } else {
                setChatError("Failed to get response from AI.");
            }
        } catch (err: any) {
            setChatError("Error: " + err.message);
        } finally {
            setChatLoading(false);
        }
    };

    return (
        <>
            {/* Chat Toggle Button */}
            <div className="fixed bottom-6 right-6 z-50">
                <button
                    className="bg-purple-600 text-white px-4 py-2 rounded shadow-lg hover:bg-purple-700"
                    onClick={() => setShowChat(!showChat)}
                >
                    {showChat ? "Close Chat" : "Open AI Chat"}
                </button>
            </div>

            {/* Chat Window */}
            {showChat && (
                <div className="fixed bottom-20 right-6 w-80 bg-white border border-gray-300 shadow-lg rounded-lg flex flex-col h-96 z-50">
                    <div className="p-3 font-semibold border-b">AI Chat Assistant</div>
                    <div className="flex-1 overflow-y-auto p-2 space-y-2 text-sm">
                        {chatHistory.map((msg, idx) => (
                            <div key={idx} className="space-y-1">
                                <div>
                                    <span className="font-medium text-gray-700">You:</span>{" "}
                                    {msg.prompt}
                                </div>
                                <div className="bg-gray-100 p-2 rounded">
                                    <span className="font-medium text-green-700">AI:</span>{" "}
                                    {msg.reply}
                                </div>
                                <div className="text-xs text-gray-400">
                                    {new Date(msg.timestamp).toLocaleString()}
                                </div>
                            </div>
                        ))}
                        {chatLoading && (
                            <div className="text-gray-500 italic">AI is thinking...</div>
                        )}
                        {chatError && <div className="text-red-500">{chatError}</div>}
                    </div>
                    <div className="p-2 border-t flex items-center">
                        <input
                            type="text"
                            value={userPrompt}
                            onChange={(e) => setUserPrompt(e.target.value)}
                            onKeyDown={(e) => e.key === "Enter" && handleSendMessage()}
                            placeholder="Type your question..."
                            className="flex-1 border border-gray-300 rounded px-2 py-1 text-sm"
                        />
                        <button
                            onClick={handleSendMessage}
                            disabled={!userPrompt || chatLoading}
                            className="ml-2 bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
                        >
                            Send
                        </button>
                    </div>
                </div>
            )}
        </>
    );
};

export default AIChatBot;
