import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    ignoreBuildErrors: true, 
  },
  eslint: {
    ignoreDuringBuilds: true, 
  },
  images: {
    // Cấu hình cho Next.js 13.4+ (remotePatterns)
    remotePatterns: [
      // --- CÁC DOMAIN GỐC CỦA BẠN ---
      { protocol: 'https', hostname: 'placehold.co', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'images.unsplash.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'picsum.photos', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'cdn.pixabay.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'images.pexels.com', port: '', pathname: '/photos/**' },
      { protocol: 'https', hostname: 'raw.githubusercontent.com', port: '', pathname: '/**' },
      
      // --- CÁC DOMAIN ĐÃ THÊM TỪ DỮ LIỆU JSON ---
      { protocol: 'https', hostname: 'lovehairstyles.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'img.freepik.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'cdn.shopify.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'www.herstylecode.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'i5.walmartimages.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'i.pinimg.com', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'content.latest-hairstyles.com', port: '', pathname: '/**' },
      // 👇 DOMAIN BỔ SUNG: PASTEL PINK COLOR 👇
      { protocol: 'https', hostname: 'www.fabmood.com', port: '', pathname: '/**' }, 
      // 👆 DOMAIN BỔ SUNG: PASTEL PINK COLOR 👆
      { protocol: 'https', hostname: 'tiki.vn', port: '', pathname: '/**' },
      { protocol: 'https', hostname: 'hairstylesweekly.com', port: '', pathname: '/**' },

    ],
    // Cấu hình bổ sung cho hình ảnh
    unoptimized: false, 
    minimumCacheTTL: 60, 
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
  // Cấu hình bổ sung cho performance
  experimental: {
    optimizeCss: true,
    optimizePackageImports: ['lodash-es', 'date-fns'],
  },
  // Cấu hình cho webpack để xử lý hình ảnh tốt hơn
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
      };
    }
    return config;
  },
};

export default nextConfig;