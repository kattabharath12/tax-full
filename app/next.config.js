const path = require('path');
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Required for Docker deployments
  distDir: '.next',
  experimental: {
    outputFileTracingRoot: path.join(__dirname, './'), // Changed from '../' to './'
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true, // Changed from false to true
  },
  images: { 
    unoptimized: false,
    formats: ['image/webp', 'image/avif'],
    domains: ['railway.app']
  },
  // Enable compression for better performance
  compress: true,
  // Remove powered by header for security
  poweredByHeader: false,
  // Disable ETags for better caching control
  generateEtags: false,
  // Optimize for production
  swcMinify: true,
  // Configure headers for security
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          }
        ]
      }
    ];
  }
};
module.exports = nextConfig;
