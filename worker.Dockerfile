FROM rust:slim-bullseye

RUN apt update && apt install curl -y && curl https://release.solana.com/v1.18.5/install -o install.sh && bash install.sh
RUN cargo install ore-cli
COPY run.ore.sh .
RUN chmod +x run.ore.sh
CMD ./run.ore.sh -r https://api.mainnet-beta.solana.com -f /root/.config/solana/id.json
