# Contributing to AI Services Platform

Thank you for your interest in contributing to the AI Services Platform! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Python 3.7+
- Git
- Google Gemini API key (for testing)

### Development Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/ai-services-platform.git
   cd ai-services-platform
   ```
3. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
5. Copy environment file:
   ```bash
   cp .env.example .env
   # Add your Gemini API key to .env
   ```

## 🛠️ Development Guidelines

### Code Style
- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add docstrings to functions and classes
- Keep functions focused and small

### Testing
- Test your changes with both services
- Run existing test scripts:
  ```bash
  python test_api.py
  python test_chatbot.py
  ```
- Add tests for new features

### Commit Messages
Use clear, descriptive commit messages:
- `feat: add new PDF analysis feature`
- `fix: resolve chatbot response formatting`
- `docs: update API documentation`
- `refactor: improve error handling`

## 📝 Types of Contributions

### 🐛 Bug Reports
When filing a bug report, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Python version)
- Error messages or logs

### 💡 Feature Requests
For new features, please:
- Describe the feature and its benefits
- Explain the use case
- Consider implementation complexity
- Discuss potential breaking changes

### 🔧 Code Contributions

#### Areas for Contribution
1. **PDF Analysis Improvements**
   - Enhanced text extraction
   - Better scoring algorithms
   - Support for more document types
   - Improved error handling

2. **Web3 Chatbot Enhancements**
   - Additional smart contract knowledge
   - Better response formatting
   - Conversation context management
   - Multi-language support

3. **Infrastructure**
   - Performance optimizations
   - Security improvements
   - Docker containerization
   - CI/CD pipelines

4. **Documentation**
   - API documentation
   - Tutorial guides
   - Code comments
   - Example implementations

#### Pull Request Process
1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes
3. Test thoroughly
4. Update documentation if needed
5. Commit with clear messages
6. Push to your fork
7. Create a Pull Request

#### Pull Request Guidelines
- Provide a clear description of changes
- Reference related issues
- Include testing instructions
- Update documentation as needed
- Ensure all tests pass

## 📋 Smart Contract Knowledge Base

### Adding New Contracts
To add new smart contract information:

1. Update `knowledge_base/contracts.json`
2. Follow the existing structure:
   ```json
   {
     "ContractName": {
       "description": "Brief description",
       "functions": {
         "functionName": "Function description"
       },
       "events": {
         "EventName": "Event description"
       },
       "key_features": {
         "feature_name": "Feature description"
       },
       "use_cases": ["use case 1", "use case 2"],
       "workflow": {
         "step_1": "First step description"
       }
     }
   }
   ```
3. Test the chatbot with questions about the new contract

### Knowledge Base Guidelines
- Use clear, non-technical language
- Include practical examples
- Explain both technical and business aspects
- Add security considerations
- Provide step-by-step workflows

## 🔒 Security

### Reporting Security Issues
- **DO NOT** open public issues for security vulnerabilities
- Email security concerns to: [security@yourproject.com]
- Include detailed description and reproduction steps

### Security Guidelines
- Never commit API keys or secrets
- Use environment variables for configuration
- Validate all user inputs
- Follow OWASP security practices

## 📚 Documentation

### Documentation Standards
- Use clear, concise language
- Include code examples
- Update README for new features
- Add inline comments for complex logic

### API Documentation
- Document all endpoints
- Include request/response examples
- Specify error codes and messages
- Update OpenAPI/Swagger specs if applicable

## 🧪 Testing

### Test Coverage
- Write tests for new features
- Test error conditions
- Verify API responses
- Test UI functionality

### Test Types
1. **Unit Tests**: Individual function testing
2. **Integration Tests**: Component interaction testing
3. **API Tests**: Endpoint functionality testing
4. **UI Tests**: User interface testing

## 🚀 Release Process

### Version Numbering
We follow Semantic Versioning (SemVer):
- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number bumped
- [ ] Changelog updated
- [ ] Release notes prepared

## 💬 Community

### Communication Channels
- GitHub Issues: Bug reports and feature requests
- GitHub Discussions: General questions and ideas
- Email: Direct contact for security issues

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow the golden rule

## ❓ Questions?

If you have questions about contributing:
1. Check existing documentation
2. Search GitHub issues
3. Ask in GitHub Discussions
4. Contact maintainers

Thank you for contributing to the AI Services Platform! 🎉
