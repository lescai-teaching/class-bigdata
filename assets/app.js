document.addEventListener("DOMContentLoaded", () => {
    const gridContainer = document.getElementById("directory-grid");
    const spinner = document.getElementById("loading-spinner");
    
    // Configuration
    const owner = "lescai-teaching";
    const repo = "class-bigdata";
    const branch = "pages";
    const apiUrl = `https://api.github.com/repos/${owner}/${repo}/contents/?ref=${branch}`;
    
    // Directories to specifically ignore
    const ignoredDirs = ['.git', '.github', 'assets'];

    async function fetchDirectories() {
        // Check cache first to avoid rate limiting
        const cachedData = sessionStorage.getItem('bigdata_dirs');
        const cacheTimestamp = sessionStorage.getItem('bigdata_dirs_time');
        
        // Cache valid for 30 minutes (1800000 ms)
        if (cachedData && cacheTimestamp && (Date.now() - cacheTimestamp < 1800000)) {
            renderCards(JSON.parse(cachedData));
            return;
        }

        try {
            const response = await fetch(apiUrl);
            
            if (!response.ok) {
                if (response.status === 403) {
                    throw new Error("GitHub API rate limit exceeded. Please try again later.");
                }
                throw new Error("Failed to fetch repository contents.");
            }
            
            const data = await response.json();
            
            // Filter for valid directories
            const directories = data.filter(item => 
                item.type === "dir" && 
                !item.name.startsWith('.') && 
                !ignoredDirs.includes(item.name)
            ).map(dir => ({
                name: dir.name,
                url: dir.html_url
            }));
            
            // Save to cache
            sessionStorage.setItem('bigdata_dirs', JSON.stringify(directories));
            sessionStorage.setItem('bigdata_dirs_time', Date.now());
            
            renderCards(directories);
            
        } catch (error) {
            console.error("Error fetching directories:", error);
            showError(error.message);
        }
    }

    function formatTitle(folderName) {
        // e.g. "pca_app" -> "Pca App", "splines_theory" -> "Splines Theory"
        return folderName
            .split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }

    function getDescription(folderName) {
        // Mocking some descriptions based on names, generic fallback
        if(folderName.toLowerCase().includes('pca')) return "Explore Principal Component Analysis interactive visualization.";
        if(folderName.toLowerCase().includes('splines')) return "Interactive models and theory behind splines and generalized additive models.";
        return `Access interactive content and applications for ${formatTitle(folderName)}.`;
    }

    function renderCards(directories) {
        // Remove spinner
        if (spinner) spinner.remove();
        
        if (directories.length === 0) {
            showError("No applications found in the repository.");
            return;
        }

        // Generate HTML
        const html = directories.map((dir, index) => {
            const title = formatTitle(dir.name);
            const desc = getDescription(dir.name);
            
            // Use relative path routing since the page is hosted on the same domain
            // The directory exists within the repository root
            const appUrl = `./${dir.name}/`;
            
            return `
                <a href="${appUrl}" class="app-card" style="animation-delay: ${index * 0.1}s">
                    <h3 class="app-title">${title}</h3>
                    <p class="app-desc">${desc}</p>
                    <div class="app-action">
                        Launch Application
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                    </div>
                </a>
            `;
        }).join('');

        gridContainer.innerHTML = html;
    }

    function showError(message) {
        if (spinner) spinner.remove();
        gridContainer.innerHTML = `<div class="error-message"><h3>Error</h3><p>${message}</p></div>`;
    }

    // Initialize!
    fetchDirectories();
});
