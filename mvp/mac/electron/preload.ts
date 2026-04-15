// Preload script for Electron
// This file is loaded before the renderer process

import { contextBridge } from 'electron'

// Expose protected methods to the renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  platform: process.platform,
})
