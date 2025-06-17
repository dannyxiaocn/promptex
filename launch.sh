#!/bin/bash

# PromptEx - Menu Bar Launch Script
echo "🚀 Building and launching PromptEx..."

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Package.swift not found. Please run this script from the PromptEx directory."
    exit 1
fi

# Build the app
echo "🔨 Building the application..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi

echo "✅ Build successful!"

# Run the app in the background
echo "📱 Starting PromptEx in menu bar mode..."
nohup swift run -c release > /dev/null 2>&1 &

# Get the process ID
APP_PID=$!

echo "✅ PromptEx is now running in the background!"
echo "📋 Menu bar icon should appear in your system tray"
echo "⌨️  Use ⌘⇧P to toggle the window or click the menu bar icon"
echo "🔢 Process ID: $APP_PID"
echo ""
echo "To stop PromptEx later, you can:"
echo "  • Click 'Quit PromptEx' from the menu bar menu"
echo "  • Or use: kill $APP_PID"
echo ""
echo "The app will remember your prompts between sessions."
echo "Enjoy using PromptEx! 🎉" 