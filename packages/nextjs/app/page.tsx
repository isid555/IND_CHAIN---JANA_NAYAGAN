"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import {
  BanknotesIcon,
  UsersIcon,
  CurrencyDollarIcon,
  SparklesIcon,
  ChartBarIcon,
  ShieldCheckIcon
} from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-eth";
import AIChatBot from "~~/app/AIChatBot";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();

  return (
      <>
        <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-100 relative overflow-hidden">
          {/* Animated Background Elements */}
          <div className="absolute inset-0 overflow-hidden">
            <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
            <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse animation-delay-2000"></div>
            <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-300 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse animation-delay-4000"></div>
          </div>

          {/* Main Content */}
          <div className="relative z-10 flex items-center flex-col grow pt-10">
            <div className="px-5 max-w-4xl mx-auto">
              {/* Hero Section */}
              <div className="text-center mb-12 animate-fade-in">
                <div className="inline-flex items-center gap-2 bg-blue-50 border border-blue-200 rounded-full px-4 py-2 mb-6">
                  <SparklesIcon className="h-4 w-4 text-blue-600" />
                  <span className="text-blue-800 text-sm font-medium">AI-Powered DeFi Platform</span>
                </div>

                <h1 className="text-center mb-8">
                  <span className="block text-2xl mb-2 text-gray-600 font-medium">Welcome to</span>
                  <span className="block text-6xl font-bold bg-gradient-to-r from-blue-600 via-blue-700 to-blue-800 bg-clip-text text-transparent leading-tight">
                  IND_CHAIN
                </span>
                  <span className="block text-xl mt-2 text-gray-600">DeFi Powered by AI Agents</span>
                </h1>

                <p className="text-lg text-gray-600 mb-8 max-w-2xl mx-auto leading-relaxed">
                  Revolutionary blockchain platform combining traditional Indian financial systems with cutting-edge DeFi technology and intelligent AI agents.
                </p>
              </div>

              {/* Connected Address Section */}
              <div className="bg-white/80 backdrop-blur-sm border border-blue-200 rounded-2xl p-6 mb-12 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
                <div className="flex justify-center items-center space-x-2 flex-col">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <p className="font-semibold text-gray-800">Connected Address:</p>
                  </div>
                  <div className="bg-blue-50 rounded-lg p-3 border border-blue-100">
                    <Address address={connectedAddress} />
                  </div>
                </div>
              </div>
            </div>

            {/* Features Section */}
            <div className="w-full bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-16">
              <div className="max-w-6xl mx-auto">
                <div className="text-center mb-12">
                  <h2 className="text-3xl font-bold text-white mb-4">DeFi Features</h2>
                  <p className="text-blue-100 text-lg">AI-powered financial services for the modern world</p>
                </div>

                <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
                  {/* Chit Fund Feature */}
                  <div className="group bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-8 text-center hover:bg-white/20 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl">
                    <div className="bg-white/20 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                      <BanknotesIcon className="h-8 w-8 text-white" />
                    </div>
                    <div className="inline-block bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold mb-3">
                      🤖 AI Powered
                    </div>
                    <h3 className="text-xl font-bold text-white mb-4">Smart Chit Fund</h3>
                    <p className="text-blue-100 leading-relaxed mb-6">
                      Revolutionize traditional chit funds with blockchain transparency and AI-driven risk assessment.
                    </p>
                    <Link href="/chitfund" passHref>
                      <div className="inline-flex items-center text-white font-medium group-hover:translate-x-1 transition-transform duration-300 cursor-pointer">
                        Join Chit Fund
                        <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </Link>
                  </div>

                  {/* Fund Raisers Feature */}
                  <div className="group bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-8 text-center hover:bg-white/20 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl">
                    <div className="bg-white/20 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                      <UsersIcon className="h-8 w-8 text-white" />
                    </div>
                    <div className="inline-block bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold mb-3">
                      🤖 AI Powered
                    </div>
                    <h3 className="text-xl font-bold text-white mb-4">Fund Raisers</h3>
                    <p className="text-blue-100 leading-relaxed mb-6">
                      Decentralized crowdfunding with AI-powered project evaluation and automated milestone tracking.
                    </p>
                    <Link href="/fundraisers" passHref>
                      <div className="inline-flex items-center text-white font-medium group-hover:translate-x-1 transition-transform duration-300 cursor-pointer">
                        Start Campaign
                        <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </Link>
                  </div>

                  {/* Remittance Feature */}
                  <div className="group bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-8 text-center hover:bg-white/20 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl">
                    <div className="bg-white/20 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                      <CurrencyDollarIcon className="h-8 w-8 text-white" />
                    </div>
                    <div className="inline-block bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold mb-3">
                      🤖 AI Powered
                    </div>
                    <h3 className="text-xl font-bold text-white mb-4">Remittance</h3>
                    <p className="text-blue-100 leading-relaxed mb-6">
                      Lightning-fast international money transfers with AI-optimized routing and minimal fees.
                    </p>
                    <Link href="/remittance" passHref>
                      <div className="inline-flex items-center text-white font-medium group-hover:translate-x-1 transition-transform duration-300 cursor-pointer">
                        Send Money
                        <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </Link>
                  </div>
                </div>

                {/* AI Agent Section */}
                <div className="mt-16 bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-8">
                  <div className="text-center mb-8">
                    <h3 className="text-2xl font-bold text-white mb-2">🤖 AI Agent Dashboard</h3>
                    <p className="text-blue-100">Intelligent agents working 24/7 to optimize your DeFi experience</p>
                  </div>

                  <div className="grid md:grid-cols-2 gap-6">
                    <div className="bg-white/10 rounded-lg p-6 border border-white/20">
                      <div className="flex items-center gap-3 mb-3">
                        <ShieldCheckIcon className="h-6 w-6 text-white" />
                        <h4 className="text-lg font-semibold text-white">Risk Assessment</h4>
                      </div>
                      <p className="text-blue-100 text-sm">AI analyzes market conditions and provides real-time risk scoring</p>
                    </div>

                    <div className="bg-white/10 rounded-lg p-6 border border-white/20">
                      <div className="flex items-center gap-3 mb-3">
                        <ChartBarIcon className="h-6 w-6 text-white" />
                        <h4 className="text-lg font-semibold text-white">Predictive Analytics</h4>
                      </div>
                      <p className="text-blue-100 text-sm">ML models predict optimal investment timing and returns</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <AIChatBot/>
        </div>

        <style jsx>{`
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        
        .animate-fade-in {
          animation: fade-in 0.8s ease-out;
        }
        
        .animation-delay-2000 {
          animation-delay: 2s;
        }
        
        .animation-delay-4000 {
          animation-delay: 4s;
        }
      `}</style>
      </>
  );
};

export default Home;