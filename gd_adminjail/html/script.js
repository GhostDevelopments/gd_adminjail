window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        const container = document.getElementById("playerList");
        container.innerHTML = "";
        
        event.data.players.forEach(player => {
            const char = JSON.parse(player.charinfo);
            const div = document.createElement("div");
            div.className = "flex items-center justify-between p-4 mb-3 rounded-xl bg-white/5 border border-white/5";
            div.innerHTML = `
                <div>
                    <div class="text-white font-600">${char.firstname} ${char.lastname}</div>
                    <div class="text-white/30 text-xs">${player.citizenid}</div>
                </div>
                <div class="text-right">
                    <div class="text-orange-400 font-800">${player.time}m</div>
                    <div class="text-white/20 text-[10px] uppercase">${player.reason}</div>
                </div>
            `;
            container.appendChild(div);
        });

        document.body.classList.remove("opacity-0", "pointer-events-none");
        document.body.classList.add("opacity-100", "pointer-events-auto");
    }
});

const closeUI = () => {
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    document.body.classList.add("opacity-0", "pointer-events-none");
    document.body.classList.remove("opacity-100", "pointer-events-auto");
};

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeUI();
});